# How to populate your DB with sample data during Hibernate bootstrap?

![](images/jpa_hibernate_data_population.png)

One of the undocumented features of Hibernate is its execution of SQL scripts given within a special file during the 
bootstrap process. It is a very useful feature in order to populate your DB with sample data during testing or development 
mode. If you create a file named `import.sql` under the project’s root classpath, and put SQL statements within it, 
Hibernate is going to execute those statements right after the schema export operation.

However, you need to be aware of one or two things while you are using `import.sql`. The first is that SQL statements you 
put into that file might be DB-specific; therefore, you need to replace its contents whenever you change your target DB. 
The second is, in order for Hibernate to process this file, its `hibernate.hbm2ddl.auto` property value should be either 
`create` or `create-drop`.

As you know, we are big fans of the Spring Application Framework, and I want to mention an alternative but much more 
flexible way provided by Spring for such sample data population requirements. By using `jdbc:embedded-database` or 
`jdbc:initialize-database` JDBC namespace elements of Spring Framework, it’s very easy to load sample data not only in 
the application scope but also specific to each individual test class in your project as well.

```xml
<jdbc:embedded-database id="dataSource">
        <jdbc:script location="classpath:schema.sql"/>
        <jdbc:script location="classpath:test-data.sql"/>
</jdbc:embedded-database>

<jdbc:initialize-database data-source="dataSource">
        <jdbc:script location="classpath:com/foo/sql/db-schema.sql"/>
        <jdbc:script location="classpath:com/foo/sql/db-test-data.sql"/>
</jdbc:initialize-database>
```

As we always say, using Hibernate with Spring in your projects makes things much easier on the Hibernate side, and you 
will become much more productive compared to using Hibernate alone.
