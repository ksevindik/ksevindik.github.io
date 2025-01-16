# Expect the Unexpected
Yes, most of the time you should expect to find out the root causes of performance degradations in your system somewhere 
else other than your first guess. We have again experienced this rule during previous days. For some period, there was an 
obvious slowness in our web applications while our web requests were being processed in the system.

First, I had thought that `SSL` enabled operations might have been creating a considerable overhead. We have `CAS SSO` 
enabled, and `CAS` always expects `HTTPS` connections during logins, ticket validations, logouts etc. There are also 
interactions among our web applications, and inter-application data sharing facilities which are performed over Spring’s 
`HTTP invoker` mechanism. I admit that it is nonsense to make `SSL` as the only scapegoat, but I had seen it as one part 
of that hassle. Anyway, this accusation had immediately disappeared, once we changed connection protocol of `HTTP invoker` 
URLs to non secure mode. Actually, the difference between peformance of `SSL` and non `SSL` was so neglectable that I had 
immediately left my first thesis, and focused on the second one: our `WebResourceLoaderPhaseListener`.

We had implemented a `JSF PhaseListener`, which gets into action after `RESTORE_VIEW` phase, and scans request if it is 
a special request to any of web resources, such as images, scripts, or style-sheets. If it is so, then it tries to find 
the actual resource in the application class path or in our relational database, and outputs its content into the web 
response. It uses `Class.getResourceAsSystem()` to load and return response content. I thought that trying to read 
contents of those resources, every time from file system, will certainly cause a performance bottleneck, at least in 
terms of expensive file I/O operations. Yes, I was partly right about existence of this performance overhead.

Browsers first try to understand if the requested resource is modified ever since the last access to it, and if it is not, 
they simply use its cached value in the local machine. It is easily achievable to indicate that resource is not modified 
just by setting response status to `HttpServletResponse.SC_NOT_MODIFIED`. If web resource’s content is streamed to client, 
we need also set `Last-Modified`, and `Expires` response headers accordingly. By that way, browser can function properly. 
Otherwise, you need to serve full content of requested web resource each time they are requested. Well, although this 
tuning helped us a bit during consecutive web resource requests, our slow performance remained as is, after this modification.

At this point, we decided to put a log statement to where that will tell us at what time our application takes its turn 
after submission of user request. By doing so, we hoped to see the delay between those two action points. Our `Log4JNDCFilter` 
filter, actually logging constructs in our project are another blog topic, plays a frontier role here. We simply put a 
`System.out.println()` statement at the beginning and end of its `doFilter` method. `Log4JNDCFilter` basically prepares 
with `NDC` and `MDC` contexts by getting some identifying values from current request, such as `contextPath`, `remoteHost`, 
`remoteAddr`, `requestURI`. I must confess here that, by chance, I also commented out `request.getRemoteHost()` statement, 
as I had thought at that time, putting only `remoteAddr` into `NDC` was enough.

Then we restarted our web application, sat and began to inspect the execution times. Hey, response time had been 
noticeably improved! At that moment, we have realized that `request.getRemoteHost()` method call was the real bottleneck, 
because it causes the web engine to resolve fully qualified name of remote host, and this causes a considerable delay 
from time to time. Well, the moral of the story shouldn’t be surprising for us. As always stated around the software 
development community, performance bottlenecks are almost always hidden in places, which are not looked for at first try.
