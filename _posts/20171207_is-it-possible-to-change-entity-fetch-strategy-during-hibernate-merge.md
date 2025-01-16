# Is It Possible To Change Entity Fetch Strategy During Hibernate Merge?

![](images/hibernate_sherlock_holmes.jpg)

When I talk with my colleague about my experience with Hibernate [merge behavior on lazy associations](http://www.kenansevindik.com/more-about-eager-initialization-of-lazy-associations-during-hibernate-merge/) 
with cascade type `merge`, he suggested me to check if Hibernate allows us to change fetch logic it applies on detached 
entities during `merge` operation. That way, it would be possible to suppress eager initialization of those associations 
during `merge`.

Hibernate executes every operation on `Session` through its corresponding `EventListener` implementation. `Merge` is no 
different in that respect. Therefore, I focused first on `DefaultMergeEventListener` in order to find the exact location 
in which `load` is performed. I reached at the following code block within `DefaultMergeEventListener`;

```java
String previousFetchProfile = source.getLoadQueryInfluencers().getInternalFetchProfile();
source.getLoadQueryInfluencers().setInternalFetchProfile( "merge" );
//we must clone embedded composite identifiers, or
//we will get back the same instance that we pass in
final Serializable clonedIdentifier = (Serializable) persister.getIdentifierType()
 .deepCopy( id, source.getFactory() );
final Object result = source.get( entityName, clonedIdentifier );
source.getLoadQueryInfluencers().setInternalFetchProfile( previousFetchProfile );
```

The key part in the above code is `source.getLoadQueryInfluencers().setInternalFetchProfile("merge");`, which implies that 
Hibernate employs an internal fetch profile identified with `"merge"` during `load` operation, and then it reverts back 
to the previous fetch profile after `load` completes. When the final `Object result = source.get(entityName, clonedIdentifier);` 
line executes, Hibernate fires `load` event this time, and `DefaultLoadEventListener` gets triggered, and a specific 
`EntityPersister` instance is used to load the entity specified with its name and identifier. `EntityPersister` uses 
`EntityLoader` implementation resolved (`CascadeEntityLoader`, in that case) according to some criteria including 
"internal fetch profile" information.

Unfortunately, neither `DefaultMergeEventListener` provides an easy way to modify "internal fetch profile" mode used, nor 
`EntityPersister` implementation to replace `CascadeEntityLoader` with another one. Hence, I had to stop my investigation 
inside Hibernate source code at this point without any useful result.

