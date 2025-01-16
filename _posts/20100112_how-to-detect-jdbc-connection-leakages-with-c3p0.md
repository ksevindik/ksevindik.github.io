# How to Detect JDBC Connection Leakages with C3P0

First of all, I must say that the whole credit for discovering this feature goes to my colleague [İlker Çelik](http://www.blogger.com/icelik@gmail.com). In a big 
codebase with lots of 3rd party libraries and frameworks interacting with JDBC connections, it might be difficult to trap 
JDBC connection leakages, which are open connections left in the application.

C3P0 connection pool has a nice option to kill unreturned connections left in the application. The `unreturnedConnectionTimeout` 
attribute is for this purpose. If you give it a positive integer value, it waits for the given seconds and then destroys 
those connections whose `close` method has not been called yet. In order to see who is responsible for the leakage, you 
must use it in combination with the `debugUnreturnedConnectionStackTraces` attribute.

If you give a positive value to `unreturnedConnectionTimeout`, C3P0 will capture the stack trace via an exception at the 
point where your application opens the connection, and setting `debugUnreturnedConnectionStackTraces` to `true` will show 
this stack trace. You can find detailed information about this feature of C3P0 [here](http://www.mchange.com/projects/c3p0/index.html#unreturnedConnectionTimeout).
