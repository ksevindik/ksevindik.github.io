---
layout: post
title: Using Hibernate StatelessSession with Spring Data Repositories
author: Kenan Sevindik
---

In his [Tech Lead Journal interview](https://www.youtube.com/watch?v=v5leZRceMuM), Gavin King reflected on a missed opportunity in Hibernate’s history: giving `StatelessSession` too little attention in the past. He later revisited the subject in his post [“A billion-dollar mistake”](https://in.relation.to/2025/09/24/a-billion-dollar-mistake/), describing his regret at underestimating its importance and not including it in the Java Persistence API right from the beginning.

I have worked with Hibernate since 2004 and with JPA since its early days, so that observation resonated strongly with me. Many applications benefit from Hibernate’s object-relational mapping, entity annotations, and query language, yet do not always need a persistence context tracking every entity they load.

A persistence context provides useful capabilities: managed entities, first-level caching, automatic dirty checking, and synchronization at flush time. But these capabilities also introduce a particular programming model that many developers find difficult to understand and unintuitive. Sometimes, we would rather load data, change it, and explicitly request a database operation, keeping things as straightforward and explicit as possible.

This was the main motivation behind [Spring Data Stateless](https://github.com/harezmi/spring-data-stateless), a project I developed to make Hibernate’s stateless persistence model available through familiar [Spring Data JPA](https://spring.io/projects/spring-data-jpa) project.

**Its primary benefit is the ability to use Hibernate as an ORM tool without a persistence context: returned entities are detached, writes happen through explicit repository calls, and a session does not accumulate managed entities.**

Version **1.0.0 is already available on [Maven Central](https://central.sonatype.com/artifact/io.github.harezmi/spring-data-stateless/1.0.0)**.

## ORM without a persistence context

Using Hibernate does not have to mean using managed entities.

With conventional Spring Data JPA, an `EntityManager`, normally backed by Hibernate’s stateful `Session`, maintains a persistence context. Inside a transaction, changes to managed entities can be persisted without an explicit repository write:

```java
@Transactional
public void rename(Long id, String name) {
    Product product = productRepository.findById(id).orElseThrow();
    product.setName(name);
    // Dirty checking can persist the change when the transaction flushes.
}
```

This is convenient when managed entity behavior fits the application. However, it also means that an in-memory mutation can become a database update without a visible write operation at that point in the code.

With a stateless repository, the corresponding operation is very explicit:

```java
@Transactional
public void rename(Long id, String name) {
    Product product = productRepository.findById(id).orElseThrow();
    product.setName(name);
    productRepository.save(product);
}
```

The product returned by the stateless repository is detached. Removing the `save()` call means that changing its name does not update the database, even though the method is transactional.

## Jakarta Data and Hibernate Data Repositories

The same interest in a stateless persistence model is reflected in Jakarta Data and Hibernate Data Repositories.

Jakarta Data defines repository APIs for data access. Hibernate Data Repositories implements that specification for relational databases using Hibernate ORM. As explained in Hibernate’s [repository programming model documentation](https://docs.hibernate.org/orm/7.0/repositories/html_single/#programming-model), these repositories use `StatelessSession` rather than an `EntityManager`.

In that model, entities are detached, updates are explicit, and association fetching must be deliberate. Hibernate generates repository implementations through an annotation processor and can validate HQL queries at compile time.

Spring Data Stateless brings stateless Hibernate access to a different repository ecosystem: **Spring Data**. It is an independent Spring Data integration, not an implementation of Jakarta Data or Hibernate Data Repositories, and it does not claim their compile-time query validation.

For Spring developers, the important consequence is that adopting stateless persistence does not require moving away from Spring Data conventions or replacing existing JPA repositories.

## Introducing Spring Data Stateless

Spring Data Stateless provides a `StatelessRepository<T, ID>` interface, repository scanning through `@EnableStatelessRepositories`, Spring Boot auto-configuration, and query execution against a transaction-bound Hibernate `StatelessSession`.

The project retains a broad set of familiar Spring Data capabilities:

- All CRUD operations, including batch `saveAll`, `deleteAll`, and `deleteAllById`.
- Derived query methods, including count, existence, and delete queries.
- JPQL, native, and named queries.
- Paging, sorting, specifications, and query by example.
- Projections, supported entity graphs, query hints, and modifying queries.

The [feature inventory](https://github.com/harezmi/spring-data-stateless/blob/main/FEATURES.md) documents the available capabilities in more detail.

The repository API remains familiar to Spring Data JPA users, while entity lifecycle behavior follows a stateless model:

| Concern | Spring Data JPA | Spring Data Stateless |
|---|---|---|
| Entity tracking | Persistence context manages loaded entities | Results are detached |
| Updates | Dirty checking can persist mutations | Explicit repository writes are required |
| First-level cache | Available through the persistence context | No first-level entity cache |
| Cascades | Configured JPA cascades apply | Stateless writes do not cascade |
| Associations | Transparent lazy loading may be available | Fetch required associations deliberately |
| Session growth | Managed entities can accumulate | No accumulation of managed entities |

Existing Jakarta Persistence entity mappings remain useful. Adopting this model nevertheless requires reviewing service behavior; changing the repository interface alone does not preserve stateful JPA semantics.

## Getting started

The 1.0.0 release targets the Spring Boot **4.1.x**, Spring Data JPA **4.1.x**, and Hibernate ORM **7.4.x** lines, with Java **17 or later**. Check the [compatibility table](https://github.com/harezmi/spring-data-stateless#compatibility) before adding it to an existing application.

In a Spring Boot project using the supported dependency management, add the standard JPA starter, Spring Data Stateless, and your database driver:

```kotlin
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("io.github.harezmi:spring-data-stateless:1.0.0")
    runtimeOnly("org.postgresql:postgresql")
}
```

The library can be used from both Java and Kotlin. The following examples use Java.

A simple entity uses ordinary Jakarta Persistence annotations:

```java
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;

@Entity
public class Product {

    @Id
    @GeneratedValue
    private Long id;

    private String name;

    protected Product() {}

    public Product(String name) {
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

Define a repository using the new base interface. For the examples below, place it in a dedicated package such as `com.example.catalog.stateless`:

```java
import io.github.harezmi.data.repository.StatelessRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProductRepository
        extends StatelessRepository<Product, Long> {

    Page<Product> findByNameContainingIgnoreCase(
            String name, Pageable pageable);

    @Query("select p from Product p where p.name = :name")
    java.util.List<Product> findWithExactName(
            @Param("name") String name);
}
```

Derived query methods, Spring Data’s `@Query`, and paging remain available. For example:

```java
Page<Product> page = productRepository.findByNameContainingIgnoreCase(
        "coffee",
        PageRequest.of(0, 20, Sort.by("name").ascending()));
```

Enable stateless repository scanning:

```java
import io.github.harezmi.data.repository.config.EnableStatelessRepositories;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableStatelessRepositories(
        basePackages = "com.example.catalog.stateless")
public class Application {
}
```

Each repository interface must be registered by exactly one repository factory. For an application using only stateless repositories, you may disable standard JPA repository auto-scanning:

```properties
spring.data.jpa.repositories.enabled=false
```

This disables JPA repository discovery, while retaining the JPA and Hibernate infrastructure. Applications using both repository types should instead configure separate scan scopes, as shown next.

## Keep existing JPA repositories and add stateless ones

You do not need to abandon Spring Data JPA to use Spring Data Stateless.

An existing application can retain its `JpaRepository` interfaces and introduce stateless repositories for selected operations. Separate their packages so the appropriate repository factory discovers each interface:

```java
@SpringBootApplication
@EnableJpaRepositories(
        basePackages = "com.example.catalog.jpa")
@EnableStatelessRepositories(
        basePackages = "com.example.catalog.stateless")
public class Application {
}
```

Here, `@EnableJpaRepositories` is Spring Data JPA’s standard annotation, and `@EnableStatelessRepositories` comes from the library.

For example, an existing `ProductJpaRepository` in the JPA package can continue to extend `JpaRepository<Product, Long>`, while `ProductRepository` in the stateless package serves workflows that require explicit writes.

Both repository types can also participate in the same Spring-managed transaction. Consider a service with constructor-injected `productRepository` and `auditEntryRepository`, where the former is stateless and the latter is a standard JPA repository:

```java
@Transactional
public void renameAndAudit(Long id, String name) {
    Product product = productRepository.findById(id).orElseThrow();

    product.setName(name);
    productRepository.save(product); // Explicit stateless write.

    auditEntryRepository.save(
            new AuditEntry("Renamed product " + id)); // Standard JPA.
}
```

With the same configured persistence unit and transaction manager, these calls share the transaction’s commit or rollback outcome. The library obtains the stateless session using the transactional Hibernate session’s connection.

**A shared transaction does not imply shared entity tracking.** Entities loaded through the stateless repository remain detached. If the same row is also managed by JPA, its in-memory state is not automatically refreshed after a stateless write. Likewise, pending JPA writes may need an explicit flush before a stateless operation depends on them.

This allows incremental adoption: keep stateful JPA behavior where it is useful and introduce stateless access where the explicit model fits better.

## Transaction boundaries still matter

Repository methods are transactional by default. Without an outer transaction, a repository call creates its own. Multiple stateless repository calls inside an outer transaction share a transaction-bound `StatelessSession`, which is closed after transaction completion.

Normal Spring rollback rules apply. Streams must be consumed inside the transaction that owns them. True nested JPA transactions are not supported by default; use `REQUIRES_NEW` when an independent inner transaction is appropriate.

The default auto-configuration expects a single candidate `EntityManagerFactory`. Applications with multiple persistence units must supply an appropriate `TransactionalStatelessSessionProvider`.

## Where this model fits

Stateless repositories are particularly useful when entities are fetched, transformed, and explicitly written: imports, exports, migrations, scheduled processing, and batch-oriented workflows are natural examples.

A stateful persistence context retains managed entities until they are cleared or the context is closed. Large processing jobs may therefore require carefully placed `flush()` and `clear()` calls. Stateless access removes that entity-tracking concern. It does not make an unbounded result list memory-efficient; large workloads still need sensible paging, streaming, or chunking.

Explicit writes can also make application behavior easier to review. A database change has a visible repository operation, rather than depending on whether a mutated object happens to be managed.

These benefits come with responsibilities. Fetch required associations explicitly using queries, projections, or supported entity graphs. Persist dependent rows in the correct order instead of relying on cascading or orphan removal. Do not assume that callbacks tied to managed entity transitions behave identically.

For rich object graphs, intentional dirty checking, and cascade-driven persistence, conventional Spring Data JPA may remain the better choice.

## Performance is something to measure

Spring Data Stateless is not intended to be a universally faster replacement for Spring Data JPA.

Avoiding entity tracking and dirty checking can reduce bookkeeping and memory pressure for suitable workloads. The actual outcome depends on the queries, database, batching, identifiers, and application behavior. Some operations may perform similarly or be slower.

The repository includes a [JMH performance example](https://github.com/harezmi/spring-data-stateless/tree/main/examples/performance) for reproducible comparisons, alongside [basic](https://github.com/harezmi/spring-data-stateless/tree/main/examples/basic) and [advanced query](https://github.com/harezmi/spring-data-stateless/tree/main/examples/advanced-queries) examples.

## Give it a try

Spring Data Stateless makes Hibernate’s stateless persistence model available without requiring Spring developers to leave familiar repository APIs behind. You can keep existing JPA repositories, add stateless repositories alongside them, and choose the appropriate model for each workflow.

Version **1.0.0** is available on Maven Central:

```text
io.github.harezmi:spring-data-stateless:1.0.0
```

Visit the [GitHub repository](https://github.com/harezmi/spring-data-stateless), explore the examples, and give it a try with a workload where detached entities and explicit writes would be useful.

I would love to hear how it works for you. Please share your use cases, report issues, and suggest improvements through the [project’s issue tracker](https://github.com/harezmi/spring-data-stateless/issues). Your feedback will help shape the next releases.