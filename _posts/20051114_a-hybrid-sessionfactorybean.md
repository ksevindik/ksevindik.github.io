# A Hybrid SessionFactoryBean
The `LocalSessionFactoryBean` is a convenient way to create and initialize a Hibernate `SessionFactory` instance in 
applications. It allows us to configure other objects and properties, such as `DataSource`, and other Hibernate properties 
that the `SessionFactory` instance depends on during initialization inside Spring's context mechanism. We can easily 
configure other parts of our application that are related to the `SessionFactory` instance in this manner. For example, 
we currently have an audit logging mechanism based on Hibernate's entity interceptor, and this part of our application 
needs to be integrated into the Spring context.

There might be cases where the `SessionFactory` must be shared across multiple applications. In such cases, we can wire 
one up via `JndiObjectFactoryBean`, starting up the `SessionFactory` instance via a separate mechanism outside the 
applications and registering it in a JNDI context as a server-wide resource in a J2EE application server environment.

We find ourselves in a similar situation as mentioned above: we have many modules, each running as a separate web 
application in our system, and each one requiring a `SessionFactory` instance. `SessionFactory` instances are identical 
across all modules, i.e., each one loads the same Hibernate mapping files, connects to the same database, and employs the 
same properties. Hence, it would be sufficient for one of those modules to bring a `SessionFactory` instance up and make 
it available to all other modules. That way, we might achieve at least a performance improvement during our modules' 
startup period.

We needed a way to start a `SessionFactory` instance up inside the Spring context and then register it as a server-wide 
resource in the JNDI context in the application server environment. Consequently, we merged the functionalities of both 
`LocalSessionFactoryBean` and `JndiObjectFactoryBean` classes to accomplish our task, and named it 
`JndiEnabledLocalSessionFactoryBean`.

It extends from `LocalSessionFactoryBean` and adds some additional properties to enable JNDI lookup, namely `jndiName`, 
`jndiAccessor`, and `enableJndiLookup`. If `enableJndiLookup` is true, it first attempts to load the `SessionFactory` 
instance from the specified JNDI location. If an available instance is found, it is provided to our application; otherwise, 
it initializes a `SessionFactory` instance and registers it to that JNDI location. This way, other modules will avoid 
initializing a new instance separately each time. If the `enableJndiLookup` property is false, it behaves as an ordinary 
`LocalSessionFactoryBean` instance, which might be preferable for a development environment.

Here is an excerpt from the source code and bean definition from the Spring context file:

```java
public class JndiEnabledLocalSessionFactoryBean extends LocalSessionFactoryBean {

    private Object sessionFactoryObject;
    private String jndiName;
    private JndiAccessor jndiAccessor;
    private boolean enableJndiLookup;

    public void afterPropertiesSet() throws IllegalArgumentException, HibernateException, IOException {
        try {
            if(isEnableJndiLookup()) {
              sessionFactoryObject = getJndiAccessor().getJndiTemplate().lookup(getJndiName());
            } else {
                initializeSessionFactory();
            }
        } catch (NamingException e) {
            initializeSessionFactory();
            try {
                 getJndiAccessor().getJndiTemplate().bind(getJndiName(),super.getObject());
            } catch (NamingException e1) {
                logger.warn("Cannot bind SessionFactory to JNDI Context",e1);
            }
        }
    }

    private void initializeSessionFactory() throws HibernateException, IOException {
        super.afterPropertiesSet();
        sessionFactoryObject = super.getObject();
    }
    public void destroy() throws HibernateException {
        if(isEnableJndiLookup()) {
               try {
                   getJndiAccessor().getJndiTemplate().unbind(getJndiName());
               } catch (NamingException e) {
                   logger.warn("Cannot unbind SessionFactory from JNDI Context",e);
               }

        }
        super.destroy();
    }

    public Object getObject() {
        return sessionFactoryObject;
    }

    //getter and setter methods for properties defined above, jndiName, jndiAccessor, enableJndiLookup
}
```

```xml
<bean id="sessionFactory" class="tbs.verisozlugu.ambar.JndiEnabledLocalSessionFactoryBean">
      <property name="configLocation">
            <value>classpath:hibernate.cfg.xml</value>
      </property>
      <property name="dataSource">
            <ref local="dataSource" />
      </property>
      <property name="jndiName">
            <value>vsSessionFactory</value>
      </property>
      <property name="enableJndiLookup">
            <value>false</value>
      </property>
      <property name="jndiAccessor">
            <ref local="jndiAccessor"/>
      </property>
</bean>

<bean id="jndiAccessor" class="org.springframework.jndi.JndiAccessor">
      <property name="jndiEnvironment">
            <value>
                  java.naming.factory.initial=org.exolab.jms.jndi.InitialContextFactory
                  java.naming.provider.url=rmi://localhost:1099
            </value>
      </property>
</bean>
```