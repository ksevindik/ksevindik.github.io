# A Transaction Gotcha When Using Spring with Hibernate

Spring’s transaction propagation rule SUPPORTS states that if there exists a transaction when the method is called, it 
should work within that transaction, otherwise it should work outside any transaction. Similarly, transaction propagation 
rule NOT_SUPPORTED states that if there exists any active transaction when the method is called, that active transaction 
should be suspended before the method is run, and the method should run outside any active transaction.

However, things work a bit oddly when the Spring transaction mechanism is used with Hibernate as the persistence technology 
at the backend. First of all, we should know that although transaction propagation is set as SUPPORTS or NOT_SUPPORTED, 
Spring still creates a logical transaction so that it can execute if there exist any registered TransactionSynchronization 
objects at the end of the method call. Another thing to know is that we also need an active physical Hibernate Transaction 
object if we want to use the contextual session feature of Hibernate in our DAO objects, and actually, the problem starts 
here. If you use the contextual session of Hibernate within your DAO objects by calling `sessionFactory.getCurrentSession()`, 
`SpringSessionContext` which is in charge of implementing the contextual session capability within the Spring environment, 
registers a `SpringSessionSynchronization` object when `getCurrentSession()` is called and switches the Hibernate Session 
flush mode to AUTO if it is MANUAL unless the transaction is marked as `readOnly=true`.

When the method completes with success, `TransactionInterceptor` performs a commit! Yes, what you read here is correct! 
Spring transaction support performs a commit whenever the method returns with success even though no actual transaction 
exists. Although `HibernateTransactionManager`, which is actually in charge of managing transactions, won’t commit as 
there is no actual transaction, it still executes registered `TransactionSynchronization` objects consecutively. 
`SpringSessionSynchronization`, at this point, invokes the Hibernate Session flush, and our SQL DML statements are sent 
to DB. Unfortunately, Hibernate's physical transaction commits when the Session is closed, even though `transaction.commit()` 
is not invoked explicitly. Hence, our changes become permanent in the DB.

This scenario is valid both for SUPPORTS and NOT_SUPPORTED propagation rules. One workaround is to mark the transaction 
as `readOnly=true`. This causes Spring to set the Hibernate Session flush mode to MANUAL, and no flush occurs during the 
`SpringSessionSynchronization.beforeCommit()` method call. The other one is to change the `transactionSynchronization` 
behavior of Spring’s `PlatformTransactionManager` to `ON_ACTUAL_TRANSACTION`. If you change it so, Spring won’t register 
any `TransactionSynchronization` object, including `SpringSessionSynchronization`. In that case, you won’t be able to use 
the contextual session capability within your DAOs. Therefore, it is better to go with the first option, and DON’T forget 
to mark your transactions as `readOnly=true` if their propagation rule is either SUPPORTS or NOT_SUPPORTED on your service 
methods.
