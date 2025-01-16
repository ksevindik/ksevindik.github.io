# Weird Rollback Behavior of Spring TestContext Framework

One of the nice features of TestContext module of Spring Application Framework is its ability to run unit tests within a 
transaction context. By that way, you are able to both execute your persistence operations which usually expect an active 
transaction to run, and also rollback state changes occur during execution of these persistence operations at the end of 
the test method invocation. TestContext module also provides you with a mechanism not to rollback, but commit in case you 
just want to inspect contents of database after the test execution, or populate the database with sample content before 
bootstrapping your application. Following code snippet shows how a unit test method can be made transactional and how 
default rollback behaviour can be switched into commit.

```java
@Test
@Rollback(false)
@Transactional
public void testTransactionalMethod() {
//...
}
```

If you invoke a transactional method of a proxy bean within this method, it inherits transaction context as expected. 
The code snippet below shows a transactional service method with default propagation (REQUIRED by default) and rollback 
rules in case an exception is thrown (rollback at RuntimeException, commit otherwise).

```java
@Service
public class TestService {
    @Transactional
    public void test() {
       if(true) throw new RuntimeException("runtime ex to trigger tx rollback");
    }
}
```

If the transaction propagation behavior of the service method is REQUIRED, then it just continues to work with the same 
physical transaction which has been started at the beginning of the test method. In case an exception is thrown within 
that method, Spring PlatformTransactionManager bean decides to mark transaction context with setRollbackOnly according 
to the provided rollback rules.

```java
@Test
@Rollback(false)
@Transactional
public void testTransactionalMethod() {
    testService.test();
}
```

In the above code snippet, transaction context is marked with setRollbackOnly as transactional service method throws the 
RuntimeException within it. When the transaction context is marked with setRollbackOnly, then Spring TestContext module 
fails at committing the transaction at the end of the unit test method. So far everything as expected. If, however, the 
RuntimeException is thrown within the unit test method, transaction initiated by the unit test is going to be committed 
at the end of the test method invocation!

```java
@Test
@Rollback(false)
@Transactional
public void testTransactionalMethod() {
    if(true) throw new RuntimeException("runtime ex to trigger tx rollback");
}
```

This might look as weird a bit if you’ve expected it to behave similar to the scenario in which a RuntimeException is 
thrown from within the service method. However, Spring TestContext module just decides on to either commit or rollback 
the transaction by looking at the @Rollback feedback provided in the test. If there is an explicit commit request via 
@Rollback(false), then TestContext just commits the transaction at the end without considering type of the exception 
thrown within it!

As a result, you should be aware of such weird behaviour in case you decide to make use of integration unit tests to 
perform database population, and need at some point just to terminate the data population whenever something related with 
the data population goes wrong. In such a case, you need to throw the RuntimeException just within the transactional 
service method in order to revert the changes in your database.


