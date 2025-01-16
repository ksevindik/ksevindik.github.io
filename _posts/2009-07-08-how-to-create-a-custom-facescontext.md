# How to create a custom FacesContext
Although I am not happy with several issues in `JSF` spec, I like its customizability. A couple of days ago, I needed to 
introduce the `Mediator` pattern in my case studies. `FacesContext` instance seemed to be a good candidate as `Mediator` 
object. You need to execute three easy steps to introduce a custom `FacesContext` implementation into your `JSF` lifecycle.

First, create your custom `FacesContext` class implementation. It is better to extend the `FacesContext` class available 
in the API. Your `FacesContext` implementation must be able to accept a `FacesContext` instance as a delegate via its 
constructor. You need to redirect calls to the delegate except for calls you will provide custom behavior. For example;

```java
public class MediatorFacesContext extends FacesContext { 
    private FacesContext delegate; 
    public MediatorFacesContext(FacesContext delegate) { 
        this.delegate = delegate; 
    } 
    //... 
}
```

After that, you need to create a custom `FacesContextFactory` implementation. It should return an instance of your custom 
`FacesContext` implementation.

```java
public class MediatorFacesFontextFacory extends FacesContextFactoryImpl { 
    public FacesContext getFacesContext(Object context, Object request, Object response, Lifecycle lifecycle) throws FacesException { 
        FacesContext defaultFacesContext = super.getFacesContext(context, request, response, lifecycle);
        MediatorFacesContext mediatorFacesContext = new MediatorFacesContext(defaultFacesContext); return mediatorFacesContext; 
    } 
}
```

Finally, in order for `JSF` implementation to use your custom factory, you need to specify it in your `faces-config.xml`.

```xml
<factory> 
    <faces-context-factory>org.speedyframework.web.jsf.handlers.MediatorFacesFontextFacory</faces-context-factory> 
</factory>
```

That’s all to have a custom `FacesContext` instance in your application.
