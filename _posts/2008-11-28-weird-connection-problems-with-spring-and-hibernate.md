# Weird Connection Problems with Spring and Hibernate
At the beginning of this week, a colleague of mine said to me that some JDBC connections were left open in one of our web 
projects. Before continuing to the rest of the story, let me first draw a rough architectural picture of the project.

We use JPA/Hibernate and Spring transactions declaratively in the data access layer. In the presentation layer, we use 
Spring WebFlow 1.0.x and keep `EntityManager` objects open as long as the current flow is active to get rid of infamous 
lazy exception problems.

After all, as we don’t directly deal with JDBC connections at any other point and have a very standard configuration of 
Spring with JPA/Hibernate, at first, I was skeptical about his observation. We keep `EntityManager` objects open as long 
as flows are active, whose duration spans user think time. First, I thought that connections are kept open as long as JPA 
`EntityManager` objects are open, and there might have been a problem in closing those `EntityManager` objects in our 
codebase. However, we quickly concluded that we were closing `EntityManager` objects properly, and apart from that, we 
found out that `EntityManager` and JDBC Connection open/close operations are not related to each other. `EntityManager` 
opens a JDBC connection when it is really needed. Specifically, it opens a new connection when a new transaction begins 
and closes it at the end of the transaction.

I then said to him that it might most probably be a bug in Hibernate and suggested upgrading Hibernate version from 3.2.6 
to 3.3.1. Unfortunately, upgrading to the latest Hibernate revision didn’t help.

After one or two days of debugging, he popped back to me and said that he had found two places which were guilty of those 
open connections. One place was in Hibernate code. We are using `dbtimestamp` type which maps to the database’s current 
timestamp, rather than JVM’s current timestamp. In `DbTimestampType` class, Hibernate uses a `PreparedStatement` to fetch 
the DB’s current timestamp. The `PreparedStatement` is closed, and its reference kept inside `Batcher` object is removed 
at the end of this operation. However, not closing the `ResultSet` retrieved while executing the `PreparedStatement` 
causes Hibernate `Batcher` object to keep a reference to the `ResultSet` object. As a result, `Batcher` object doesn’t 
close JDBC connection as it still has a reference to that `ResultSet`.

There is also an [open issue](https://hibernate.atlassian.net/browse/HHH-2455) in Hibernate JIRA which is closely related 
to our case. Instead of waiting for the next release of Hibernate for the solution, we decided to copy `DbTimestampType`’s 
source code, fix the problem, and create our own user type namely `dbtimestamp2` instead of Hibernate’s registered 
`dbtimestamp` type.

The second place which was under suspicion as being the cause of those open connections was Spring’s `HibernateJpaDialect` 
class. Spring’s `JpaTransactionManager` exposes `JpaTransactionObject` as `JdbcTransactionObject` when `DataSource` 
object in `JpaTransactionManager` is not null. This might occur in cases when JPA is configured in standalone mode or a 
`DataSource` object is injected directly into the `JpaTransactionManager`. By that way, plain JDBC operations are able to 
share the same transaction context as with JPA operations. `JpaTransactionManager` does this by first getting a 
`Connection` object through calling configured `JpaDialect`’s `getJdbcConnection()` method, and then binding `DataSource` 
object together with this connection in the current thread context.

If we examine `HibernateJpaDialect.getJdbcConnection()` method closely, we see that `Connection` is retrieved by calling 
`Session.connection()` method. `Session.connection()` method returns a borrowed connection which is actually a proxy 
object to `java.sql.Connection`. Application code accesses the actual JDBC connection through the borrowed connection. 
Hibernate’s `ConnectionManager` manages borrowed connection by keeping a reference to it when it is instantiated, and 
removes the reference when its private `cleanup()` method is called. `cleanup()` method actually calls 
`ConnectionManager.releaseBorrowedConnection()` method to release it. Another case which triggers borrowed connection 
release is calling `close()` method of borrowed connection itself. The conditions at which `cleanup()` is called method 
are listed in Hibernate source code as follows;

- At the end of the Session
- At manual disconnect of the Session
- From `afterTransaction()`, in the case of skipped aggressive releasing

When we look at those three locations, we see that it is called at the first two points; however, there is no `cleanup()` 
call in `ConnectionManager.afterTransaction()` method. Calling `afterTransaction()` method causes physical JDBC 
connection to be closed, but as `cleanup()` method is not called, borrowed connection is not released after transaction 
completion.

The problem actually begins after transaction completions. When we trigger a JDBC statement to be executed without a 
transaction, for example, by accessing a lazy collection’s elements, Hibernate opens a new JDBC connection to fetch 
collection elements from DB. If connection release mode of Hibernate is set to **AFTER_STATEMENT** or **AFTER_TRANSACTION** 
(provided there is no active TX at that point), then Hibernate attempts to close JDBC connection by calling 
`afterStatement()` method. Unfortunately, connection cannot be closed if `borrowedConnection` is not null, in other 
words, there is a reference to a borrowed connection object. As you remember this reference is left after previously 
executed transaction. As a result, the physical JDBC connection will be kept open until a new transaction is initiated 
or Session is closed, or it is manually disconnected. In our case if user stories have many non-transactional data 
access, or they require long user think time, keeping `EntityManager`/`Session` open until the end of the flow, might 
cause connections to be exhausted.

`JpaTransactionManager` does a resource clean up after transaction completion and calls `JpaDialect`’s 
`releaseJdbcConnection()` method. However, `HibernateJpaDialect` does nothing in its `releaseJdbcConnection()`. If it 
were called previously retrieved connection’s `close()` method, it would cause the release of borrowed connection, 
because as I said before the connection returned from Session was actually borrowed connection, which is a Connection 
proxy, calling its close method triggers `ConnectionManager`’s `releaseBorrowedConnection`.
