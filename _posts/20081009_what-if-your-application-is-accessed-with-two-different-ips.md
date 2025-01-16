# What If Your Application is Accessed With Two Different IPs
We have recently deployed one of our projects into the production environment. Our customer is located abroad, and we 
perform deployments and acceptance tests over the Internet. They use the system within their local network by accessing 
it from a fake IP, like `192.x.x.x`. In other words, our system is accessed from two different networks.

The real problem arose when a web cache configuration was introduced into the scene. As you remember from 
[one of my previous posts](http://blog.harezmi.com.tr/dealing-with-http-response-redirects-within-oracle-web-cache-deployed-environments/), 
I had mentioned dealing with `sendRedirects` within web cache-enabled environments. In summary, we were 
prepending `appUrl` to the location string before calling the `sendRedirect` method. However, as we cannot determine from 
which network a user will come during deployment time, it is not possible to prepare a valid `appUrl` for all those 
requests. What is worse is that there is no DNS installed in this environment.

The first solution that came to my mind was that we can simply call `ServletRequest`'s `getRemoteAddr()` method to 
determine from which network the current request is initiated. It returns the IP address of the client or the last proxy 
that sent the request, and according to the type of IP (it will be either a real or fake IP in our case), we could have 
chosen an appropriate `appUrl` to prepend. In fact, there is a better solution which was found by one of my colleagues; 
it is `getLocalAddr()`. This method returns the IP address of the interface on which the request is received. As a result, 
there is no need to keep two different `appUrls` based on the type of client IP. We can easily call `getLocalAddr()` 
method to get the IP and compose an `appUrl` with it and then prepend that `appUrl` to the location URL inside 
`sendRedirect` method.

In conclusion, I was once more reminded that we should always discard the first solution that comes to our minds, and try 
to find one more, which will probably be better than the first one, as much as possible.
