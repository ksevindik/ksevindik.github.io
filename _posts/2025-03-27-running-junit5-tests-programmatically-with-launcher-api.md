---
layout: post
title: Running JUnit 5 Tests Programmatically with Launcher API
author: Kenan Sevindik
---

JUnit 5 provides a powerful Launcher API that allows developers to programmatically discover and execute tests. This is 
particularly useful for custom test execution workflows, automated test runs, and dynamic test selection. In this blog 
post, I will walk through a simple Kotlin example that demonstrates how to use the JUnit 5 Launcher API to run a 
predefined set of test classes.

Below is the Kotlin program that uses JUnit 5's Launcher API to execute a list of test classes:

```kotlin
fun main() {
    val testClasses = listOf(
        EventTrackerKafkaProducerTest::class.java,
        FrequentlyBoughtTogetherConsumerTest::class.java,
        CouponMigrationConsumerTest::class.java,
        CouponTest::class.java,
        VolumeSavingsStrategyIntegrationTest::class.java
    )

    val request = LauncherDiscoveryRequestBuilder.request().selectors(
        testClasses.map { DiscoverySelectors.selectClass(it) }
    ).build()

    val launcher = LauncherFactory.create()
    val listener = SummaryGeneratingListener()
    launcher.registerTestExecutionListeners(listener)
    launcher.execute(request)

    val summary: TestExecutionSummary = listener.summary
    println("Tests executed: ${summary.testsFoundCount}")
    println("Failures: ${summary.failures.size}")
    summary.failures.forEach { 
        println("Failed: ${it.testIdentifier.displayName} - ${it.exception.message}") 
    }
}
```

## Breakdown of the Code

### 1. Defining the Test Classes
```kotlin
val testClasses = listOf(
    FooTest::class.java,
    BarTest::class.java,
    BazTest::class.java
)
```
A list of test classes is defined, which will be executed programmatically.

### 2. Creating a Discovery Request
```kotlin
val request = LauncherDiscoveryRequestBuilder.request().selectors(
    testClasses.map { DiscoverySelectors.selectClass(it) }
).build()
```
A `LauncherDiscoveryRequest` is built to discover the specified test classes. JUnit 5 provides multiple `DiscoverySelectors` 
that allow selecting tests in different ways. Besides selecting individual classes using `selectClass()`, you can choose 
specific test methods with `selectMethod()`, discover all tests in a package using `selectPackage()`, or dynamically select 
tests from classpath roots, directories, and files. This flexibility allows you to fine-tune test discovery based on your 
requirements. For example, if you need to execute all tests in a directory, you can use `selectDirectory()`, or if you 
want to run a single method from a test class, `selectMethod()` is the best choice. Combining multiple selectors enables 
even more dynamic test execution strategies.


### 3. Creating the Launcher and Listener
```kotlin
val launcher = LauncherFactory.create()
val listener = SummaryGeneratingListener()
launcher.registerTestExecutionListeners(listener)
```
A `Launcher` instance is created using `LauncherFactory.create()`. Later it will be used to execute the tests. A 
`SummaryGeneratingListener` is instantiated to capture test execution details, and finally the listener is registered to 
track test execution events.

### 4. Executing the Tests
```kotlin
launcher.execute(request)
```
The test execution starts.

### 5. Summarizing the Results
```kotlin
val summary: TestExecutionSummary = listener.summary
println("Tests executed: ${summary.testsFoundCount}")
println("Failures: ${summary.failures.size}")
summary.failures.forEach { 
    println("Failed: ${it.testIdentifier.displayName} - ${it.exception.message}") 
}
```
When the execution finishes, the test execution summary is retrieved. The total number of executed tests and failures is 
printed. Any failed tests are listed with their names and error messages.

## Conclusion

The JUnit 5 Launcher API provides a flexible way to run tests programmatically. Tests can be dynamically selected and 
executed based on custom logic. It is ideal for embedding test execution in CI/CD pipelines or custom test runners.
In this blogpost, I tried to demonstrate how to select test classes, execute them, and generate a summary of the results. 
By using this approach, you can customize your test execution strategy and integrate testing into automated workflows 
efficiently.

