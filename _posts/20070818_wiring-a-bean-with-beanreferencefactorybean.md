# Wiring a Bean with BeanReferenceFactoryBean
For some reason or another, you may have more than one bean definition with the same type configured in your application 
context, and you may want to use only one of them based on some condition or configuration option.

For example, I have two `PlatformTransactionManager` beans configured in my application context.

```xml
<bean id="jdbcTransactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource" />
 </bean>

<bean id="jpaTransactionManager" class="org.springframework.orm.jpa.JpaTransactionManager">
    <property name="entityManagerFactory" ref="entityManagerFactory" />
</bean>
```

I configure both transaction manager beans in my configuration and expect the developer to choose one that is appropriate 
for the persistence mechanism used in the application. If they use IBatis or JdbcTemplate and perform database operations 
with direct JDBC calls, then they will choose `jdbcTransactionManager`. If they use Hibernate with JPA, then they will be 
expected to choose `jpaTransactionManager` instead.

With the above configuration, I have one obvious problem with executing integration tests which extend from Spring’s 
`AbstractTransactionalSpringContextTests` class. If bean wiring is `AUTOWIRE_BY_TYPE`, which is the default, then they 
will complain that there are more than one bean instances with `PlatformTransactionManager` in the context. On the other 
hand, if the bean wiring mode is `AUTOWIRE_BY_NAME`, then injection won’t be performed as the `AbstractTransactionalSpringContextTests` 
class expects a bean with the name `transactionManager` exactly in the context.

Yes, it is possible to rename one of them as `transactionManager` and continue with the work. However, this is not a very 
good solution, as for example, if I rename `jdbcTransactionManager` to `transactionManager` then integration tests with 
JPA codes won’t function properly.

```xml
<bean id="transactionManager" class="org.springframework.beans.factory.config.BeanReferenceFactoryBean">
    <property name="targetBeanName">
        <value>${db.transaction.manager.bean}</value>
    </property>
</bean>
```

I need a more flexible solution. Spring’s `BeanReferenceFactoryBean` class comes to the rescue here. `BeanReferenceFactoryBean` 
exposes another bean instance, configured in the context, according to its `targetBeanName` property. Developers can provide 
the `targetBeanName` property value through `db.transaction.manager.bean` placeholder, which is replaced with the actual 
bean name, `jdbcTransactionManager` or `jpaTransactionManager` using Spring’s `PropertyPlaceholderConfigurer` mechanism.
