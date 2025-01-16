# Deployment Driven Development
I had almost forgotten this type of software development after I started using lightweight J2EE technologies, like 
`Spring`, and `Hibernate`. Recently, however, I had to involve with a project, some part of it depends on `EJBs`! What 
is worse is that they were `EJB 2.1`. After trying mock approach with `mockejb` and playing with `open-ejb` and `geronimo` 
for local deployment sometime without any reasonable outcome, we decided to directly deploy the application into our target 
environment because of the tight schedule constraints of project.

Well, actually deployment of `EJB’s` happened without any problem. We were still lucky until that step, but when it came 
to test our application, development process somehow turned out to a “deploy, test, debug, and code” cycle, what I call 
it as “deployment driven development”. Other than this cycle, you have hardly any choice to see if there is any hole in 
business logic, invalid SQL expression, or any other bug in the system. If, for example, there is a little invalid SQL 
expression within your BMP entity bean, or forgot to provide some value to a compulsory field, you have to first package 
your `EJBs`, create an `EAR` and perform several container specific steps to deploy them.

I know, some of those problems could have been easily resolved with a level of abstraction among `EJB` specific classes 
and code in which actual job performed, but this couldn’t be always possible, especially if you’re partly involving with 
the system. Moreover, apart from those, it is always possible that development process could easily turn into 
“deployment driven” mode while working with `EJBs`. In summary, working with `EJBs` is a real mess!
