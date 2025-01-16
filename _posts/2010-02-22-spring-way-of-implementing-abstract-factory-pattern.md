# Spring Way of Implementing Abstract Factory Pattern

In my current work, I am responsible for developing a platform to ease web application development using several JEE 
technologies such as JSF, SWF, Spring, and JPA/Hibernate or Toplink. One main consideration of our management is to keep 
the platform as flexible as possible in terms of which ORM tool is used. Every web application that is built on top of 
this platform should be able to choose either Toplink or Hibernate.

I am aware of the impossibility of keeping a platform ORM-agnostic with the use of JPA. My aim in this post is not to 
criticize JPA, but to share a simple way of isolating ORM vendor-specific codes in a layered architecture. We employ a 
classical layered approach in our platform, in which presentation, web controller, service, and data access layers exist. 
In the service layer, we provide several general-purpose services, such as transactional CRUD operation services, security, 
auditing services, etc. We usually perform data access in those services, and therefore, a DAO layer with related data 
access operations is laid underneath.

During the development process, we came up with situations where it was necessary to provide both Hibernate and 
Toplink-specific implementations of those DAO classes. One such example exists in generic CRUD operations. We want to 
provide a QBE facility through our services layer; however, each ORM vendor has its proprietary solutions for it. As a 
result, the following class hierarchy appeared in our `entityDao` facility.

It is highly possible to have similar hierarchies for other DAO classes as well. At runtime, we want to isolate higher 
layers, such as the service layer, from the ORM vendor choice and make the system function with either Hibernate or 
Toplink by just some configuration property changes. In other words, we want to provide our services layer with a family 
of related objects, in this case, DAO objects, depending on a system configuration. As you may remember from the seminal 
book of GOF, the abstract factory pattern makes changing product families very easy and also promotes consistency among 
products. This means it is not possible to mix products from different families. On the other hand, it is difficult to 
introduce new products into the scene, as it requires changing the abstract factory interface. Unfortunately, we cannot 
foresee what kind of DAO classes we will need, hence it is critical for us to be able to add new kinds of DAOs without 
any effort or modification in the system.

You may ask, how does Spring help us in this situation? Well, it is its bean configuration and overriding mechanism that 
help us solve the issue of adding new kinds of products in the product families. Spring's bean configuration mechanism 
has many nice and useful features, and one of them I often make use of is its bean overriding mechanism. You can define 
more than one bean with the same ID in your application context files, and the one in the last loaded application context 
file will override other bean definitions with the same IDs. As a result, we only need to create different bean configuration 
files for each ORM vendor and define exactly the same beans with IDs in each of them.

```xml
<bean id="entityService" class="org.ems4j.services.EntityServiceImpl">
    <property name="entityDao" ref="entityDao"/>
</bean>

<bean id="securityService" class="org.ems4j.services.SecurityServiceImpl">
    <property name="entityDao" ref="entityDao"/>    
    <property name="securityDao" ref="securityDao"/>
    <property name="encodedPasswordCreator" ref="encodedPasswordCreator"/>
</bean>
```

As you see, our entityService and securityService beans depend on DAO beans. All we need to create `daos-hibernate.xml` 
and `daos-toplink.xml` like below, and configure only one of them in the runtime.

daos-hibernate.xml

```xml
<bean id="entityDao" class="org.ems4j.dao.EntityDaoJpaHibernateImpl">
    <property name="jpaTemplate" ref="jpaTemplate"/>
</bean>

<bean id="securityDao" class="org.ems4j.dao.SecurtityDaoJpaHibernateImpl">
    <property name="jpaTemplate" ref="jpaTemplate"/>
</bean>
```

daos-toplink.xml

```xml
<bean id="entityDao" class="org.ems4j.dao.EntityDaoJpaToplinkImpl">
    <property name="jpaTemplate" ref="jpaTemplate"/>
</bean>

<bean id="securityDao" class="org.ems4j.dao.SecurityDaoJpaToplinkImpl">
    <property name="jpaTemplate" ref="jpaTemplate"/>
</bean>
```
```xml
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>
        classpath*:/appcontext/services.xml
        classpath*:/appcontext/daos-hibernate.xml
    </param-value>
</context-param>
```
When loading spring application context, you may list those bean configuration files in your `web.xml` as follows. Let’s 
assume you chose Hibernate as ORM in this case;

In summary, when you need to add new DAO classes in your platform, all you need to do is implement them in your codebase 
and add their bean definitions into the corresponding bean configuration files.
