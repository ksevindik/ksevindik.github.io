# TransactionTemplate and Rollback Rules

When I was playing with `TransactionTemplate` during one of my Spring training sessions, I promptly suggested the 
audience try changing the default rollback rules while using `TransactionTemplate`. After all, `TransactionTemplate` 
encapsulates boilerplate transaction begin, commit/rollback statements, and we only give the business logic part, which 
it executes inside that begin…commit/rollback block. Because of this, I’ve thought so far that `TransactionTemplate`’s 
behavior would be the same as declarative transaction management’s. In other words, it would rollback if the exception 
is unchecked, otherwise commit if the exception is checked, and it would be possible to change this default behavior. 
Therefore, I implemented a code very similar to the following and expected to see commit even though the code throws 
`RuntimeException`.

```java
RuleBasedTransactionAttribute rules = new RuleBasedTransactionAttribute();
rules.getRollbackRules().add(new NoRollbackRuleAttribute(RuntimeException.class));

TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager,rules);

transactionTemplate.execute(new TransactionCallbackWithoutResult() {

    @Override
    protected void doInTransactionWithoutResult(TransactionStatus status) {

        if(true) throw new RuntimeException();

    }
});
```

Unfortunately, I was plain wrong! `TransactionTemplate` continued to rollback without taking my custom no-rollback rule 
defnition into account. I was surprised and looked into `TransactionTemplate`’s source code, and saw following code block;

```java
public  T execute(TransactionCallback action) throws TransactionException {
    if (this.transactionManager instanceof CallbackPreferringPlatformTransactionManager) {
        return ((CallbackPreferringPlatformTransactionManager) this.transactionManager).execute(this, action);
    }
    else {
        TransactionStatus status = this.transactionManager.getTransaction(this);
        T result;
        try {
            result = action.doInTransaction(status);
        } catch (RuntimeException ex) {
            // Transactional code threw application exception -> rollback
            rollbackOnException(status, ex);
            throw ex;
        } catch (Error err) {
            // Transactional code threw error -> rollback
            rollbackOnException(status, err);
            throw err;
        } catch (Exception ex) {
            // Transactional code threw unexpected exception -> rollback
            rollbackOnException(status, ex);
            throw new UndeclaredThrowableException(ex, "TransactionCallback threw undeclared checked exception");
        }
        this.transactionManager.commit(status);
        return result;
    }
}
```

`TransactionTemplate` rollbacks on any exception without consulting `RuleBasedTransactionAttribute` at all. It was 
strange because, after all, it was expecting `TransactionDefinition` as a constructor argument, and I thought that it 
would be possible to give custom rollback rules instead of the default one, even though `TransactionTemplate` extends 
from `DefaultTransactionDefinition`. If you look at that constructor closely, you will notice that all parameters of the 
`TransactionDefinition` input argument are copied to `TransactionTemplate` except rollback rules. Therefore, they are 
simply ignored!

In summary, it appears that Spring guys probably assumed that it would be meaningless to deal with rollback rules if 
someone does programmatic transaction management. The programmer would decide on whether to commit or rollback on any 
exception after all. This would be meaningful if one uses `PlatformTransactionManager` for programmatic transaction 
management, but `TransactionTemplate` is a bit different in my point of view. It hides common and repeating boilerplate 
code, and it would be better if this code had taken rollback rules into account when an exception occurred.
