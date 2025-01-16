# Applet Life Cycle Issues in Internet Explorer
In the previous blog entry, I had just mentioned about our server-side context sharing mechanism between an `Applet` and 
web pages in our GIS-enabled project. Users will try to accomplish their scenarios by using those two views. Obviously, 
there will be switches many times between them during the execution of any use case. Simply, users will enter some data 
via the web interface and then switch to the `Applet` view and enter some further data there and then switch back to the 
web interface and submit data. Later, they will switch to the `Applet` view again to see the results of that submit action.

There is one big problem here. As the web interface part and `Applet` view part will be in different web pages, IE calls 
the `destroy` method of the `Applet` instance each time when we leave the page in which the `Applet` resides and calls 
`init` each time when we enter into that page again. IE behaves like this between page back and forward operations, too. 
According to the specified operations above, the life cycle of an `Applet` in IE is as follows:

```pseudo
init() -> start()	: when we enter the page, in which our applet is contained

stop() -> destory()	: when we leave applet page, or click page back/forward buttons

init() -> start()	: when we again come back to the applet's web page
```

As a result of the above behavior, our GIS `Applet` gets initialized several times during the execution of a user scenario, 
which is unacceptable because users may enter some data, open several maps during their operations, and may also switch 
back and forth between the `Applet` and web interface part.

I tried to find an elegant solution to this multiple `init` -> `destroy` problem. I looked for a way to prevent the 
browser from calling those methods but came up without a solution. Through deep googling around the web, I found 
relatively old discussions (dating back to the year 2000 in comp.lang.java.programmer) related to our problem. I think 
the only possible solution to this problem is caching state, data, or graphics, which you don’t want to get destroyed and 
initialized again in a static data structure in your `Applet` code. In the `init()` method, or during other phases of the 
`Applet`, you first look at the cache before you create your graphics or load user data and only create or initialize them 
unless they exist in the static cache. This cache could simply be a `Hashtable`. The trick here is that the loaded `Applet` 
class definition and therefore static variable are kept alive until all open browser windows are closed.
