# Be Careful When Using Parent-Child Associations in Hibernate

Parent-child relationships are a special case of more general 1:M associations. They are simply part-whole relationships 
and for Hibernate it is not meaningful that parts (children) should exist without belonging to a whole (parent).

Parent-child association is specified with the `orphanRemoval` attribute of the `@OneToMany` annotation. Hibernate 
achieves this by employing a special persistent collection implementation.

The first thing you should be aware of is that when a child entity is just removed from its containing collection (e.g., 
`children.remove(child)`), Hibernate issues an SQL DELETE statement at flush time for that child entity without expecting 
an explicit `session.delete(child)` call. Remove operations are tracked by that persistent collection and removal of a 
child means that it becomes orphaned, and orphaned children should be immediately deleted.

Another important point is that when you want to get rid of all of the children in a collection, just call 
`children.clear()`. If you try to set the parent’s collection property value to `NULL` (for example, 
`parent.setChildren(null)`), you will get an `HibernateException` with the following message:  
**"A collection with `cascade="all-delete-orphan"` was no longer referenced by the owning entity instance."**  

This message tells us that the collection instance used to manage the parent-child relationship is de-referenced by its 
parent. In other words, the connection between the two is just lost. However, this exception only arises when you perform 
the `NULL` set operation on the attached parent entity. If the parent is detached, you can safely set its `children` 
property to `NULL` and then reattach it to the session. Reattachment will cause all of its children to be deleted as well.
