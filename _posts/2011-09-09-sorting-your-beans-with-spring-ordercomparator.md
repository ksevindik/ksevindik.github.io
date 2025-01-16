# Sorting Your Beans With Spring OrderComparator

Sometimes you may need to execute your collection of beans in a specified order. For example, in one of our projects, we 
have a collection of EventHandlers which operate when certain Events occur. For each event, there might be more than one 
EventHandler instance that needs to operate. Most of the time, it is not important if one executes before the other or vice 
versa. However, from time to time, there happens that some EventHandler instances should wait for the successful completion 
of some other EventHandler instances. The rest could still operate in unspecified order.

At this point, we just want those instances to be ordered among themselves and ignore others. Thanks to Spring, it provides 
a simple but nice `OrderComparator` implementation exactly for this purpose. It is simply used to sort instances implementing 
Spring’s `Ordered` interface, putting those other instances not implementing that interface at the end of the collection, 
in arbitrary order.

We manage `EventHandler` instances as Spring beans and inject them into another bean as an array. That bean implements 
Spring’s `InitializingBean` interface as well, so that after the `EventHandler` collection property is initialized properly, 
it could be sorted out using `OrderComparator`. For this purpose, `Arrays.sort()` or `Collections.sort()` static methods 
could be used, both having the collection or objects and a `Comparator` instance as input parameters.

