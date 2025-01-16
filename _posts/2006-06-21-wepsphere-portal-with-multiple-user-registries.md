# Wepsphere Portal with Multiple User Registries
In our project, we employ the `Websphere Portal` product. Some of our users are defined in `Active Directory` and some 
others are defined in a relational database. As you may know, `Websphere Portal` has support for `Active Directory` as 
its user registry, but as we also have user definitions outside of `Active Directory`, we need a way to provide all the 
user information to the portal in a unified way. We discussed several options related to this requirement together with 
an IBM representative some time ago. I want to list, and make some comments about them below;

* One possible solution is to map each different user in our relational database to a unique user in `Active Directory`. 
Obviously, this is not a very attractive solution. It will most probably cause problems when our users want to make 
customizations to their portal accounts. Simply skipped this one. After all, for what a portal exists at all?

* Inserting user definitions into an `Active Directory` leaf for our users that exist in the relational DB. This looks like 
an acceptable offer at first, but we have some limitations in our project in modifying our customer’s `Active Directory` 
to add other users’ definitions. Sorry for this!

* Another solution is to implement a custom user registry interface. It provides read-only user information to `Websphere` 
through a predefined interface. The IBM consultant commented that choosing a custom user registry will bring one more 
workload, which is implementing `WMM` (`Websphere Member Manager`), not a trivial task, and using a custom user registry 
also causes some `SSO` integration problems when used together with `Lotus Sametime` product. Hence, we skipped this 
one, too.

* Finally, we can configure an `LDAP` compatible directory server as our portal’s user registry and populate user definitions 
from `Active Directory` and the relational database at runtime. We also employ `Trust Association Interceptor` for integrating 
the portal into our `SSO` architecture, and `TAI` could easily check if there exists an entry for the current user in that 
directory server, and if not, it will insert one.

After a round table discussion about the above suggestions, we preferred to employ the fourth one. It doesn’t bring any 
difference in terms of configuring the portal’s user registry, and we don’t need to modify our customer’s `Active Directory`. 
Custom user registry looks at first very promising, but things don’t go very smoothly among IBM products.
