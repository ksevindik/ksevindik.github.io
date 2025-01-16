# Acegi Security Extensions Project
`AcegiSecurityFramework` for Spring is a highly popular enterprise security framework for web applications. It provides 
many authentication and authorization features of very high quality. With the use of `Acegi`, it is now a practical reality 
to be able to add security features to your system from the ground up without any difficulty.

I have created a new open-source project called `acegi-ext`. It is located at http://sourceforge.net/projects/acegi-ext. 
The main aim of the `acegi-ext` project is to provide additional capabilities to the `AcegiSecurityFramework`, such as 
declarative management of ACL entries, support for `AcegiSecurity` in portal environments, and constraint-based security 
features over a role-based authorization mechanism. There is also [documentation](http://ksevindik.googlepages.com/AcegiSecurityPortletIntegration-0.1.doc) 
explaining how to enable `Acegi` within portlets and use authentication and authorization features in general, including 
ACL management features. These three add-ins came into existence after my considerable experiences with `AcegiSecurity` 
in enterprise-scale projects.

The `AcegiPortlet` component is designed to help portlets use authorization features inside JSR-168 compliant portals. 
I have already made it work with Liferay Portal 4.2.2 and JBoss Portal 2.6.1 releases. Other portal adaptations are in 
progress!

`AcegiAclManagement` aims to ease adding, deleting, or updating ACL entries of domain objects while they are manipulated 
in the system. It does its work using AOP and Java 5 annotations, with a totally declarative fashion in nature.

The third component, namely constraint-based security, is still in the theoretical phase. Constraints are features that 
will be applied over existing user–role relationships.

I will try to improve all these solutions, perhaps add some other components in the future, and give detailed explanations 
from here over time. Keep in touch…
