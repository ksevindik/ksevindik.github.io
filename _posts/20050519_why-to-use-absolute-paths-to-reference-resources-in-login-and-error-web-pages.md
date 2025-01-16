# Why to use absolute paths to reference resources in login and error web pages
I think it is a well-known practice to use absolute names to access resources in login and global error pages, but the 
reason behind it might not be so clear for some of us. The Servlet specification states that when a protected resource 
is accessed, the request should be directed first to the login page unless the user is authenticated, but it leaves how 
this direction will happen ambiguous. As a result, implementations may differ among several web containers.

If a web container sends a redirect response to the browser, relative resources will be resolved based on the location of 
the login or error page, so using non-absolute paths will work in that case. However, if forwarding is preferred by the 
container, relative resources may be broken as the browser will try to resolve them relative to the currently requested 
protected resource’s URL.

The best way to solve this kind of problem is always to use absolute paths in login and error pages to refer to other 
resources.