# How to build SessionFactory in Hibernate 4

Well, I think it is the first time in Hibernate’s history that it is released with incomplete feature implementations and 
documentation. I came to this conclusion when I see `Configuration.buildSessionFactory()` method as deprecated.

When I look at the documentation, however, it still uses the above method to create it! If you look at the 
`org.hibernate.cfg.Configuration` class, it is stated that the configuration mechanism of Hibernate will be replaced with 
`ServiceRegistryBuilder` and `MetadataSources` classes after 4.0, so `Configuration` is made “deprecated” and will be 
removed in Hibernate 5. On 22nd May, Hibernate 4.2.2 is released, but there is still no example of how to build 
`SessionFactory` with the new way in its own documentation!

OK, I didn’t stop at that point and tried to configure it with the new way by googling around and find some examples 
which are also given by Hibernate’s team members like below;

```java
ServiceRegistry registry = new ServiceRegistryBuilder().configure().buildServiceRegistry();

sessionFactory = new MetadataSources(registry)
	.addAnnotatedClass(Foo.class).buildMetadata()
	.buildSessionFactory();
```

However, I realized that `hibernate.cfg.xml` has switched from DTD to XSD, and we have to update its header to reflect 
this. Still, same story, there is no mention of this change in the documentation. Anyway, I changed configuration file 
as follows and continued with my trials.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<hibernate-configuration
xmlns="http://www.hibernate.org/xsd/hibernate-configuration"
xsi:schemaLocation="http://www.hibernate.org/xsd/hibernate-configuration hibernate-configuration-4.0.xsd"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<session-factory>
...
</session-factory>
</hibernate-configuration>
```

After this change I tried again but came up with the following error!

```stacktrace
Caused by: java.lang.NullPointerException
at org.hibernate.persister.entity.AbstractEntityPersister.initSubclassPropertyAliasesMap(AbstractEntityPersister.java:2285)
at org.hibernate.persister.entity.SingleTableEntityPersister.(SingleTableEntityPersister.java:711)
at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
```

My Entity class is super simple, only containing a “synthetic id” in it.

```java
package examples.model;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class Foo {
	@Id
	@GeneratedValue
	private Long id;
}
```

Error point indicates that Hibernate is unable to identify type of entity’s identifier attribute. At this point, I 
reverted to old configuration and saw that it works without any problem!

There are some other examples with both use `Configutation.configure()` and then build SessionFactory with the new approach 
like below;

```java
Configuration cfg = new Configuration();
cfg.configure();
sessionFactory = cfg.buildSessionFactory(new ServiceRegistryBuilder()
	.applySettings(cfg.getProperties()).buildServiceRegistry());
```

Be careful that you won’t forget to call `applySettings(cfg.getProperties())`, otherwise your property definitions in 
`hibernate.cfg.xml` won’t override definitions in `hibernate.properties`! Still discovered with trial and error.

Unfortunately, you cannot register Hibernate event listeners via `hibernate.cfg.xml` anymore. In order to register them, 
you first need to create an `org.hibernate.integrator.spi.Integrator` implementation like below:

```java
public class TestIntegrator implements Integrator {

	@Override
	public void integrate(Configuration configuration,
		SessionFactoryImplementor sessionFactory,
		SessionFactoryServiceRegistry serviceRegistry) {
		EventListenerRegistry service = serviceRegistry.getService(org.hibernate.event.service.spi.EventListenerRegistry.class);
		service.appendListeners(EventType.LOAD, TestLoadListener.class);
	}
//...
}
```

Then you will create a file called `org.hibernate.integrator.spi.Integrator` in the `/META-INF/services` folder and put 
the FQN of your `Integrator` implementation class inside it. You can put more than one line; each will be a different 
`Integrator` class.

As a result, it is better to keep using the old approach in order to build `SessionFactory` until the new configuration 
approach is completely ready to use.
