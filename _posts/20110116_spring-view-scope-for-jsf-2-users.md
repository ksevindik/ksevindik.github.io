# Spring View Scope For JSF 2 Users

In JSF 2, there are several new scopes introduced for managed beans, and one of them is view scope. As any developer who 
deals with JSF and Spring knows, it is much better to define your JSF managed beans in the Spring application context 
instead of dealing with the primitive DI container of JSF itself.

Those who know me know that I am not using JSF in my own projects anymore. However, JSF is used for UI development in a 
project where I have responsibility on the backend side, and in that project, JSF managed beans were defined on the JSF 
side. Some of them were scoped with view. When we decided to move those beans into the Spring application context, we 
needed a view scope implementation.

When I searched for a ready-to-use view scope implementation around the Internet, I only came up with one or two code 
pieces that did not support life-cycle callbacks from the Spring side. Therefore, I decided to implement a new one from 
scratch and put it here for those who may need it in their own projects as well.

```java
public class ViewScope implements Scope {
	public static final String VIEW_SCOPE_CALLBACKS = "viewScope.callbacks";
	public synchronized Object get(String name, ObjectFactory<?> objectFactory) {
		Object instance = getViewMap().get(name);
		if(instance == null) {
			instance = objectFactory.getObject();
			getViewMap().put(name,instance);
		}
		return instance;
	}
	public Object remove(String name) {
		Object instance = getViewMap().remove(name);
		if(instance != null) {
			Map<string,Runnable> callbacks = (Map<string, Runnable>) getViewMap().get(VIEW_SCOPE_CALLBACKS);
			if(callbacks != null) {
				callbacks.remove(name);
			}
		}
		return instance;
	}
	public void registerDestructionCallback(String name, Runnable runnable) {
		Map<string,Runnable> callbacks = (Map<string, Runnable>) getViewMap().get(VIEW_SCOPE_CALLBACKS);
		if(callbacks != null) {
			callbacks.put(name,runnable);
		}
	}
	public Object resolveContextualObject(String name) {
		FacesContext facesContext = FacesContext.getCurrentInstance();
		FacesRequestAttributes facesRequestAttributes = new FacesRequestAttributes(facesContext);
		return facesRequestAttributes.resolveReference(name);
	}
	public String getConversationId() {
		FacesContext facesContext = FacesContext.getCurrentInstance();
		FacesRequestAttributes facesRequestAttributes = new FacesRequestAttributes(facesContext);
		return facesRequestAttributes.getSessionId() + "-" + facesContext.getViewRoot().getViewId();
	}
	private Map<string,Object> getViewMap() {
		return FacesContext.getCurrentInstance().getViewRoot().getViewMap();
	}
}
```

As you may have noticed, destruction callbacks are also kept in the JSF view map. I also made use of Spring’s 
`FacesRequestAttributes` in order to provide answers for contextual object queries like view, request, session, application, 
etc. The conversation ID has to be unique for each view instance. Therefore, I prefixed the current view ID with the session 
ID so that it became unique across different users who access the same view.

We need a point to initialize the callbacks map. Fortunately, JSF 2 provides a system event facility that notifies view 
map post-construction and pre-destruction phases. Therefore, I also implemented a `ViewMapListener` to initialize the 
callbacks map after view map construction and execute destruction callbacks just before view map cleanup.

```java
public class ViewScopeCallbackRegistrar implements ViewMapListener {
	public void processEvent(SystemEvent event) throws AbortProcessingException {
		if(event instanceof PostConstructViewMapEvent) {
			PostConstructViewMapEvent viewMapEvent = (PostConstructViewMapEvent)event;
			UIViewRoot viewRoot = (UIViewRoot)viewMapEvent.getComponent();
			viewRoot.getViewMap().put(ViewScope.VIEW_SCOPE_CALLBACKS,new HashMap<string,Runnable>());
		} else if(event instanceof PreDestroyViewMapEvent) {
			PreDestroyViewMapEvent viewMapEvent = (PreDestroyViewMapEvent)event;
			UIViewRoot viewRoot = (UIViewRoot)viewMapEvent.getComponent();
			Map<string,Runnable> callbacks = (Map<string, Runnable>) viewRoot.getViewMap().get(ViewScope.VIEW_SCOPE_CALLBACKS);
			if(callbacks != null) {
				for(Runnable c:callbacks.values()) {
					c.run();
				}
				callbacks.clear();
			}
		}
	}

	public boolean isListenerForSource(Object source) {
		return source instanceof UIViewRoot;
	}
}
```

Finally, we have to configure these two parts on both the Spring and JSF sides. To use the view scope, we have to introduce 
it to Spring in some way. I prefer the declarative way. We need to define a `CustomScopeConfigurer` bean in the Spring 
application context and add the “view” scope as a new entry.

```xml
<bean class="org.springframework.beans.factory.config.CustomScopeConfigurer">
    <property name="scopes">
        <map>
            <entry key="view">
                <bean class="com.example.ViewScope"/>
            </entry>
        </map>
    </property>
</bean>
```

For the JSF side, we have to register our `ViewMapListener` in the application element of `faces-config.xml`.

```xml
<system-event-listener>
    <system-event-listener-class>com.example.ViewScopeCallbackRegistrar</system-event-listener-class>
    <system-event-class>javax.faces.event.PostConstructViewMapEvent</system-event-class>
    <source-class>javax.faces.component.UIViewRoot</source-class>
</system-event-listener>

<system-event-listener>
    <system-event-listener-class>com.example.ViewScopeCallbackRegistrar</system-event-listener-class>
    <system-event-class>javax.faces.event.PreDestroyViewMapEvent</system-event-class>
    <source-class>javax.faces.component.UIViewRoot</source-class>
</system-event-listener>
```
