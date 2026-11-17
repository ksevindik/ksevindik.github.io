---
layout: post
title: Spring Kafka Retry - Beyond @RetryableTopic
author: Kenan Sevindik
---

Designing an effective retry strategy requires more than simply deciding how many times a failed operation should be 
retried. Spring Kafka provides a flexible retry infrastructure, but making the right architectural choices requires 
understanding how its mechanisms work, how they interact, and where their limitations lie.

This article is the first part of a two-part series exploring retry strategies in Spring Kafka. In this part, we examine 
the framework's built-in retry mechanisms, including blocking and non-blocking retries, exception classification, backoff 
policies, topic reuse, and dead-letter handling. The second part will focus on more advanced scenarios, exploring custom 
retry strategies, consumer pause/resume, circuit breakers, and recovery mechanisms for prolonged downstream failures.

## 1. Retry Is More Than Just Trying Again

Message processing in Kafka-based applications can fail for many reasons. A database connection may be lost, an external 
service may become temporarily unavailable, or an incoming message may violate the application's business rules.

However, not all failures should be handled in the same way.

For example, retrying a payment operation a few milliseconds after a brief database connection failure may make sense. 
If an external payment provider remains unavailable for hours, continuously retrying the same operation will only increase 
resource consumption.

A retry architecture should answer four fundamental questions:

1. **Which failures should be retried?** How should retryable and non-retryable exceptions be distinguished?
2. **When and how many times should retries occur?** Which backoff policy should be used?
3. **Where should retries take place?** Within the current consumer processing flow or on a separate retry topic?
4. **What should happen when retries are exhausted?** Should the message be sent to a DLT, or should another recovery workflow be initiated?

Spring Kafka allows us to manage much of this behavior without implementing custom retry loops or retry consumers within 
the application.

To use the framework's capabilities correctly, however, we need to understand how its retry mechanisms work and where 
their limitations lie.

## 2. Blocking and Non-Blocking Retry

Historically, Kafka-based applications have also used the terms *hot retry* and *cold retry*. Today, Spring Kafka 
documentation more commonly uses *blocking retry* and *non-blocking retry*.

Hot retry refers to reprocessing a failed message at short intervals, usually within the existing consumer processing flow. 
Cold retry refers to reprocessing a message after longer delays, typically through separate retry topics.

Spring Kafka supports both mechanisms.

### Blocking Retry

Blocking retry reprocesses a failed message through the error-handling mechanism of the same listener container.

Spring Kafka uses `DefaultErrorHandler` for this purpose.

```java
@Bean
DefaultErrorHandler errorHandler() {
    return new DefaultErrorHandler(
        new FixedBackOff(100L, 3L)
    );
}
```

With this configuration, three additional retries are performed after the initial processing attempt fails. There is a 
100-millisecond delay between retry attempts.

The message is not moved to a separate retry topic. This approach is suitable for short-lived transient failures, but a 
failed message can delay the processing of subsequent messages in the same partition.

### Non-Blocking Retry

Non-blocking retry works by moving a failed message to a separate retry topic.

```java
@RetryableTopic(
    attempts = "4",
    backoff = @Backoff(delay = 60_000)
)
@KafkaListener(topics = "payments")
public void consume(PaymentEvent event) {
    paymentService.process(event);
}
```

Spring Kafka configures the necessary retry topics, listener containers, and DLT routing infrastructure.

Instead of waiting for the failed message's retry time, the main consumer can continue processing subsequent messages.

However, this comes at an important cost:

**With non-blocking retry, the original processing order of messages in the source topic is no longer preserved.**

Spring Kafka's non-blocking retry mechanism is not supported with batch listeners or container transactions.

### Can Blocking and Non-Blocking Retry Be Used Together?

Yes.

For example, three blocking retries can be attempted first for short-lived connection failures. If these attempts fail, 
the message can be routed to a non-blocking retry topic.

This approach attempts to resolve short-lived transient failures quickly while preventing prolonged failures from 
continuously occupying the main consumer.

## 3. Retryable and Non-Retryable Exceptions

One of the first responsibilities of a retry mechanism is to determine whether a failed operation is suitable for retrying.

A **retryable exception** represents a failure for which repeating the same operation later has a reasonable chance of 
succeeding.

A **non-retryable exception** represents a failure for which processing the same message again under the same conditions 
is not expected to succeed.

| Failure | Possible strategy |
|---|---|
| Database connection timeout | Short blocking retry, followed by non-blocking retry |
| HTTP 503 | Non-blocking retry with exponential backoff |
| HTTP 429 | Delay aligned with the rate-limiting policy |
| Invalid payment amount | No retry |
| Unknown payment status | Query the current status or perform reconciliation first |
| Serialization/schema error | Usually DLT or separate intervention |

The exception type alone is not always sufficient.

For example, a timeout from a payment provider does not necessarily mean the transaction failed. The payment may have 
completed successfully even though the response was never received.

In that case, querying the existing transaction status may be necessary before submitting the operation again.

Retryability therefore depends not only on the technical exception class but also on the business semantics of the operation.

Spring Kafka considers certain exception types fatal by default. These include `DeserializationException`, 
`MessageConversionException`, `ConversionException`, `MethodArgumentResolutionException`, `NoSuchMethodException`, 
and `ClassCastException`.

Exception classification policies can be configured separately for blocking and non-blocking retry mechanisms.

**An exception being retryable does not mean it should be retried through every retry mechanism.**

## 4. How Does Non-Blocking Retry Work?

The Kafka broker does not act as a scheduler that delivers messages at a specified future time through the standard topic 
mechanism.

Spring Kafka manages the delay on the consumer side.

```text
payments
    |
    | Processing failed
    v
payments-retry-120000
    |
    | Wait until retry timestamp
    v
Retry processing
```

The flow works as follows:

1. An exception occurs while the listener processes a message.
2. Spring Kafka determines the appropriate retry destination.
3. The message is immediately published to the retry topic.
4. A retry timestamp header is added to the message.
5. The retry consumer polls the message.
6. If the scheduled processing time has not arrived, the relevant partition is paused.
7. When the scheduled time arrives, the partition is resumed and the message is delivered to the listener.

In this model, Kafka stores the message while Spring Kafka manages delayed processing.

### Head-of-Line Blocking

If the first message in a retry consumer's partition is not yet due for processing, subsequent messages may have to wait 
even if their scheduled processing times have already arrived.

```text
Partition 0

Offset 100 → Due at 16:00
Offset 101 → Due at 15:00
Offset 102 → Due at 15:30
```

At 15:45, offsets 101 and 102 may already be due, but the partition may still be paused because of offset 100.

Therefore, retry topic design should consider partition count, concurrency, delay distribution, and backlog together.

Also, a retry timestamp does not guarantee an exact processing time. Actual processing may occur later due to consumer 
scheduling, polling cycles, and system load.

## 5. Core Components of Spring Kafka's Retry Architecture

Although `@RetryableTopic` provides a relatively simple API, several components behind it handle different responsibilities.

| Component | Responsibility |
|---|---|
| `RetryTopicConfiguration` | Represents the retry policy |
| `BackOffValuesGenerator` | Calculates retry delays |
| `DestinationTopicPropertiesFactory` | Builds the destination topology |
| `DefaultDestinationTopicResolver` | Resolves destinations at runtime |
| `DeadLetterPublishingRecovererFactory` | Provides retry/DLT publishing infrastructure |

We can examine these components in two main phases.

**Bootstrap:**

```text
Retry Configuration
        |
        v
BackOffValuesGenerator
        |
        v
DestinationTopicPropertiesFactory
        |
        v
Destination Topology
        |
        v
Listener / Resolver Registration
```

**Runtime:**

```text
Listener Failure
        |
        v
Blocking Retry (if configured)
        |
        v
Exception Classification
        |
        v
DefaultDestinationTopicResolver
        |
        v
Retry Topic / DLT
        |
        v
Delayed Consumption
```

This distinction is important for understanding why Spring Kafka calculates the retry topology at application startup.

## 6. Backoff Policy and Topic Reuse Strategy

Two concepts in Spring Kafka's retry architecture must be distinguished.

A **Backoff Policy** determines how long to wait between retry attempts.

A **Topic Reuse Strategy** determines whether multiple retry attempts can share the same physical Kafka topic.

Consider the following backoff sequence:

```text
2m → 6h → 12h → 12h → 12h
```

This policy includes five retry attempts. However, these attempts do not necessarily require five separate physical retry 
topics.

### MULTIPLE_TOPICS

A separate destination is used for each retry attempt.

```text
main
  ↓
retry-2m
  ↓
retry-6h
  ↓
retry-12h-0
  ↓
retry-12h-1
  ↓
retry-12h-2
  ↓
DLT
```

### SINGLE_TOPIC

Consecutive attempts with identical delays at the end of the retry chain can share the same physical topic.

```text
main
  ↓
retry-2m
  ↓
retry-6h
  ↓
retry-12h ↺ ↺
  ↓
DLT
```

As of Spring Kafka 4.1, `SINGLE_TOPIC` is the default behavior for identical intervals.

### SINGLE_TOPIC with Fixed Backoff

If all retry attempts use the same delay, a single retry topic is sufficient.

For example:

```text
2m → 2m → 2m
```

This policy can be implemented with `SINGLE_TOPIC` as follows:

```text
main
  ↓
retry-2m
  ↺
  ↺
  ↓
DLT
```

```java
@RetryableTopic(
    attempts = "4",
    backoff = @Backoff(delay = 120_000),
    sameIntervalTopicReuseStrategy =
        SameIntervalTopicReuseStrategy.SINGLE_TOPIC
)
@KafkaListener(topics = "payments")
public void consume(PaymentEvent event) {
    paymentService.process(event);
}
```

Here, `attempts = "4"` means four attempts including the initial processing attempt, or three retries.

All three retries take place on the same physical retry topic.

### Comparing Backoff Policies and Topic Reuse

| Backoff strategy | Example delays | SINGLE_TOPIC | MULTIPLE_TOPICS |
|---|---|---|---|
| Fixed | 2m, 2m, 2m | 1 topic | 3 topics |
| Exponential | 2m, 4m, 8m | 3 topics | 3 topics |
| Exponential + maxDelay | 2m, 6h, 12h, 12h, 12h | 3 topics | 5 topics |
| Custom, repeated intermediate intervals | 2m, 2m, 6h, 6h, 12h, 12h | 5 topics | 6 topics |

The important point is this:

**`SINGLE_TOPIC` is not a general-purpose topic reuse algorithm that automatically merges all identical delays.**

For example:

```text
2m → 2m → 6h → 6h → 12h → 12h
```

Under the standard `SINGLE_TOPIC` behavior, only the repeated 12-hour intervals at the end are merged.

Consequently, six retry attempts require five physical retry topics.

To understand why, we need to examine the implementation of `DefaultDestinationTopicResolver`.

## 7. How Does DefaultDestinationTopicResolver Work?

`DefaultDestinationTopicResolver` is one of the core components that determines where a failed message should be routed 
in Spring Kafka's non-blocking retry mechanism.

### Destination Topology and Runtime Routing

At application startup, Spring Kafka builds a list of destinations from the retry configuration. The resolver stores 
these relationships in a structure accessible through the listener ID and topic name.

In simplified form:

```java
Map<String, Map<String, DestinationTopicHolder>>
    sourceDestinationsHolderMap;
```

Each `DestinationTopicHolder` maintains the relationship between the current destination and the next destination.

For example:

```text
payments
    → payments-retry-120000

payments-retry-120000
    → payments-retry-21600000

payments-retry-21600000
    → payments-retry-43200000

payments-retry-43200000
    → payments-dlt
```

This topology is built during bootstrap. It is not recalculated for every message at runtime.

When message processing fails, the following resolver method is called:

```java
resolveDestinationTopic(
    String mainListenerId,
    String topic,
    Integer attempt,
    Exception e,
    long originalTimestamp
)
```

The resolver first evaluates whether the message is eligible for another retry:

- Has the retry attempt limit been exceeded?
- Is the exception retryable?
- Has the exception been classified as fatal?
- Has the retry timeout expired?

If retrying is not possible, the message is routed to the appropriate DLT destination or no-ops destination.

If retrying is possible, the next destination is selected.

At this point, an important characteristic of `resolveRetryDestination()` becomes apparent: the method does not take the 
`attempt` parameter.

Conceptually, the core routing behavior looks like this:

```java
if (sourceDestination.isReusableRetryTopic()) {
    return sourceDestination;
}

if (nextDestination.isDltTopic()) {
    return getDltOrNoOpsDestination(...);
}

return nextDestination;
```

This code is not an exact copy of the source implementation; it is a simplified representation of its behavior.

**The `attempt` value affects retry eligibility. However, when a retry is allowed, the decision to reuse the current topic 
or move to the next destination is not based on a general-purpose, attempt-driven routing algorithm.**

### Why Can't Intermediate Retry Topics Be Reused?

Consider this retry policy:

```text
2m → 2m → 6h → 6h → 12h → 12h
```

Ideally, we might want to use only three physical retry topics:

```text
retry-2m  ↺
    ↓
retry-6h  ↺
    ↓
retry-12h ↺
    ↓
DLT
```

To achieve this, `retry-2m` would need behavior such as:

```text
attempt 1 → retry-2m
attempt 2 → retry-6h
```

Similarly, `retry-6h` would need:

```text
attempt 3 → retry-6h
attempt 4 → retry-12h
```

However, the current resolver does not perform this kind of *attempt-aware stage transition*.

When a destination is marked as reusable, the resolver returns that same destination as long as the retry conditions are 
satisfied.

Therefore, there is no general-purpose stage counter that allows a reusable intermediate topic to publish back to itself 
a specified number of times before advancing to the next retry stage.

Spring Kafka's topology generation and destination validation logic also restrict reusable retry topics to repeated 
intervals at the end of the chain.

The limitation is therefore not confined to the resolver method's implementation.

**Destination topology generation, validation rules, and the runtime routing algorithm together produce this behavior.**

### Architectural Implications

`DefaultDestinationTopicResolver` reveals an important design choice in Spring Kafka's retry infrastructure.

Instead of dynamically calculating a retry plan for every message at runtime, the framework follows a destination 
topology established during bootstrap.

This approach simplifies configuration, makes routing behavior predictable, and reduces the need to develop custom retry 
infrastructure.

The trade-off is reduced flexibility in certain scenarios.

In particular, reusing topics at intermediate stages of the retry chain is not supported by the current standard model.

## 8. Retry Configuration

Let's consider a concrete payment system scenario.

Suppose our requirements are:

- Perform three fast blocking retries if the initial processing attempt fails.
- Then wait two minutes.
- After the next failure, wait six hours.
- Apply a twelve-hour delay to subsequent attempts.
- Limit the retry window to approximately thirty days.
- Route non-retryable messages or messages that exhaust their attempts to the DLT.

### Non-Blocking Retry

```java
@RetryableTopic(
    attempts = "62",
    backoff = @Backoff(
        delay = 120_000,
        multiplier = 180,
        maxDelay = 43_200_000
    ),
    timeout = "2592000000",
    include = RetryablePaymentException.class,
    sameIntervalTopicReuseStrategy =
        SameIntervalTopicReuseStrategy.SINGLE_TOPIC,
    retryTopicSuffix = "-retry",
    dltTopicSuffix = "-dlt"
)
@KafkaListener(
    topics = "payments",
    groupId = "payment-processor"
)
public void consume(PaymentEvent event) {
    paymentService.process(event);
}
```

Here:

- `attempts` specifies the total number of non-blocking processing attempts, including the initial processing attempt.
- The first retry delay is 2 minutes.
- The second retry delay is 6 hours.
- Subsequent delays are capped at 12 hours.
- The repeated intervals at the end share the same physical retry topic.
- `timeout` defines a retry window of approximately 30 days.

When the timeout expires, the message is not automatically moved to the DLT at that exact moment. The timeout is evaluated 
during the next failure and destination resolution.

### Adding Blocking Retry

```java
@Configuration
@EnableKafka
public class PaymentRetryConfiguration
        extends RetryTopicConfigurationSupport {

    @Override
    protected void configureBlockingRetries(
            BlockingRetriesConfigurer retries) {

        retries
            .retryOn(RetryablePaymentException.class)
            .backOff(new FixedBackOff(100L, 3L));
    }
}
```

With this configuration, three additional blocking retries can be performed at each processing stage.

This combines hot and cold retry behavior into a single processing strategy.

### DLT Handling

When retry attempts are exhausted or a message is classified as non-retryable, Spring Kafka can route it to a Dead Letter 
Topic (DLT).

`@DltHandler` can be used to process messages consumed from the DLT created by `@RetryableTopic`.

```java
@DltHandler
public void handleDlt(
        PaymentEvent event,
        @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) {

    log.error(
        "Payment event sent to DLT. topic={}, event={}",
        topic,
        event
    );
}
```

`@DltHandler` is declared in the same class as the corresponding `@KafkaListener`. It can also be shared by multiple 
retryable listeners in that class.

This method can record the cause of the failure, create an operational record, or initiate a manual intervention process.

However, **reaching the DLT and successfully processing the DLT message are not the same thing.**

For example, the handler above only logs the message. When the handler completes normally, the DLT consumer may consider 
the message processed. In production, a persistent failure record or operational tracking mechanism is more reliable than 
logging alone.

The behavior applied when an exception occurs inside `@DltHandler` can be controlled through `dltProcessingFailureStrategy`. 
By default, a message that fails during DLT processing may be published back to the DLT; the `FAIL_ON_ERROR` strategy can 
change this behavior.

Rather than having the DLT handler send the message directly to the beginning of the retry chain, reprocessing should 
preferably be managed through a controlled recovery mechanism.

### Programmatic Configuration

As an alternative to annotation-based configuration, `RetryTopicConfigurationBuilder` can be used.

```java
@Bean
RetryTopicConfiguration paymentRetryConfiguration(
        KafkaTemplate<String, PaymentEvent> template) {

    return RetryTopicConfigurationBuilder
        .newInstance()
        .includeTopic("payments")
        .retryOn(RetryablePaymentException.class)
        .exponentialBackoff(
            120_000,
            180,
            43_200_000
        )
        .maxAttempts(62)
        .timeoutAfter(2_592_000_000L)
        .useSingleTopicForSameIntervals()
        .create(template);
}
```

With this approach, `@RetryableTopic` is not required on the listener.

Programmatic configuration is particularly useful for centrally managing retry policies and using the framework's 
customization points.

### Operational Configuration Notes

By default, Spring Kafka constructs topic names using suffixes and delay or index values.

```text
payments-retry-120000
payments-retry-21600000
payments-retry-43200000
payments-dlt
```

Naming can be customized through `RetryTopicNamesProviderFactory`. However, changing topic naming does not change the 
retry topology.

Similarly, `autoCreateTopics=false` disables Spring Kafka's topic creation, but it does not change how the retry topology 
is calculated.

In production environments, the Kafka broker's `auto.create.topics.enable` setting and the listener container's 
`missingTopicsFatal` setting should also be considered together.

## 9. Conclusion

In short, Spring Kafka supports both blocking and non-blocking retry mechanisms.

These mechanisms can satisfy many retry requirements without application developers having to implement custom retry 
schedulers, consumers, or routing infrastructure.

However, retry design involves more than adding a few parameters to the `@RetryableTopic` annotation.

Exception classification, execution model, backoff policy, topic reuse strategy, and DLT handling must be considered together.

As we saw with `DefaultDestinationTopicResolver`, the framework's declarative conveniences are built on specific 
architectural choices. Understanding these choices is essential both for configuring the framework correctly and for 
recognizing its limitations.

But are the standard retry mechanisms sufficient for every scenario?

For example, if a downstream API remains unavailable for hours, is it appropriate to keep moving messages between retry 
topics? And how should we approach a solution when we need to reuse intermediate retry topics?

In the second part of this series, we will explore these questions through custom retry, consumer pause/resume, circuit 
breaker, and DLT recovery strategies.
