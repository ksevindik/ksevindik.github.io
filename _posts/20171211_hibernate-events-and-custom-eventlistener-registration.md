# Hibernate Events and Custom EventListener Registration

![](images/event_listener.jpg)

Since Hibernate 3, each and every operation through Session API fires one or more persistence events during the course 
of its execution. For example, when you invoke session.get(Foo.class,1L), in order to fetch Foo entity with PK 1, 
Hibernate fires events with pre-load, load and post-load event types. There is a seperate EventListener interface for 
each different event type as well, therefore you can easily create a custom EventListener to intercept Hibernate’s load 
operation, and execute custom logic before, at and after the entity load process. Indeed, Hibernate also implements those 
EventListeners in order to bring to life its own built-in functions in Session. The following example shows a custom 
EventListeners for pre-load, load and post-load events.

```java
public class CustomPreLoadEventListener implements PreLoadEventListener {

 @Override
 public void onPreLoad(PreLoadEvent event) {
  System.out.println(event.getEntityName() + " with id " + event.getId() + " will be loaded");
 }

}

public class CustomLoadEventListener implements LoadEventListener {

 @Override
 public void onLoad(LoadEvent event, LoadType loadType) throws HibernateException {
  System.out.println(event.getEntityClassName() + " with id " + event.getEntityId() + " is being loaded now");
 }

}

public class CustomPostLoadEventListener implements PostLoadEventListener {

 @Override
 public void onPostLoad(PostLoadEvent event) {
  System.out.println("Entity with id " + event.getId() + " has been loaded :" + event.getEntity());
 }

}
```

Hibernate provides us with two different configuration mechanisms, one is declarative, and the other is programmatic, 
in order to register those custom EventListeners into the event subsystem. Hibernate even allows you to deactivate its 
default EventListeners, hence you can completely change Hibernate’s built-in persistence behavior.

Let’s have a closer look at those two different configuration mechanisms.

## Declarative Configuration

After implementing custom EventListener classes, you need to define them within the hibernate.cfg.xml file in order to 
active them during specific event occurrences. The below example shows different EventListener registrations for different 
event types.

```xml
<hibernate-configuration>
 <session-factory>
  <event type="pre-load">
   <listener class="x.y.z.CustomPreLoadEventListener"/>
  </event>
  <listener class="x.y.z.CustomLoadEventListener" type="load"/>
  <listener class="x.y.z.CustomPostLoadEventListener" type="post-load"/>
 </session-factory>
</hibernate-configuration>
```

Declarative approach always appends custom EventListeners defined after the default ones. It gives us no way to prepend, 
or replace those built-in listeners.

## Programmatic Configuration

Programmatic approach is more versatile compared to declarative one but with the cost of writing some more code in your 
application. You have complete control at what EventListeners will move in, and in which order. Programmatic customization 
process is based on Hibernate’s pluggable service registry architecture. You first need to implement Integrator interface 
in order to access EventListenerRegistry object, in order to register your own EventListeners. Following code example 
illustrates how you can prepend or append custom EventListeners, or completely deactivate the default one.

```java
public class CustomEventListenerIntegrator implements Integrator {

 @Override
 public void integrate(Metadata metadata, SessionFactoryImplementor sessionFactory,
 SessionFactoryServiceRegistry serviceRegistry) {
  EventListenerRegistry eventListenerRegistry = serviceRegistry.getService(EventListenerRegistry.class);
  eventListenerRegistry.setListeners(EventType.PRE_LOAD, CustomPreLoadEventListener.class);
  eventListenerRegistry.appendListeners(EventType.LOAD, CustomLoadEventListener.class);
  eventListenerRegistry.prependListeners(EventType.POST_LOAD, CustomPostLoadEventListener.class);
 }

 @Override
 public void disintegrate(SessionFactoryImplementor sessionFactory, SessionFactoryServiceRegistry serviceRegistry) {
 
 }

}
```

After implementing custom Integrator class for EventListener registration, it is time to introduce it to Hibernat’s service 
subsystem so that it will be instantiated and executed during the bootstrap process. For that purpose, you need to create 
a file called org.hibernate.integrator.spi.Integrator in /META-INF/services folder in your project’s classpath, and add 
FQN of your custom Integrator class in it.

Happy event handling with Hibernate! 🙂


