# A Criteria Builder Idiom for Hibernate Queries

This simple idiom continuously appears in our search/find use cases, and several other ones, which have parts, in which 
we find some data to act on it, according to some specific condition.

In search/find use cases, users enter some data pattern, select some options, and enter date ranges to narrow or broaden 
the result of those queries. We needed a way to carry those entries from the user to the DAO layer for the preparation of 
queries. Hence, we declared an `ICriterionBag` interface, which is actually a marker interface. In its subclasses, we 
defined properties and their getters/setters mainly, to carry those entries of users from the presentation layer to the 
DAO layer. It is also possible to specify some other properties for Hibernate queries, such as maximum result count, or 
match mode for search patterns, and so on.

In the DAO layer, we had to somehow translate those entries into Hibernate Criteria objects, and then execute them to 
have query results. Therefore, we declared an interface, called `ICriteriaBuilder`, in which there is only one method 
declaration, which takes an open Hibernate Session, and `ICriterionBag` object as input, and finally returns a Hibernate 
Criteria object as output. In subclasses, we first created a Hibernate Criteria object, and then added `Criterion` objects 
into it, according to the specified entries in the `ICriterionBag` object.

The frequency of defining new `ICriterionBag`, and `ICriteriaBuilder` subtypes isn’t so much related to the diversity of 
use cases, but types of returned entities from those queries. Therefore, you may reuse already defined types in several 
previous use cases. As a result, some properties in `ICriterionBag` are becoming only meaningful for some use cases, and 
some other properties are for others.
