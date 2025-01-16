# Proxying Tomcat with Apache HTTP Server
There is a bunch of step by step tutorials and good references about putting `Apache` in front of `Tomcat` around net. 
Nevertheless, I wrote this article, mainly for myself, in case I come up with same requirement in sometime later.

First, let me give a little background information about problem. We have served `JIRA` through `Tomcat` for only our 
internal use so far. Recently, we have come up with a requirement of letting customers located outside to access `JIRA`. 
The network architecture doesn’t allow direct access to internal systems, instead there is a `DMZ` to put those services 
which need to be accessed from outside world. However, it was not a wise approach to move `JIRA` installation to `DMZ` 
zone to open it outside world. Therefore, we decided to put an `Apache HTTP Server` into `DMZ` and make it forward 
requests to `Tomcat` instance running in internal network. Hence, solution will be built upon `Apache 2.2.x` and 
`Tomcat 6.0.x`.

In order to integrate `Apache` with `Tomcat`, `mod_jk` module needs to be loaded and configured. Here are the main steps 
and configuration parts to achieve this.

Configure a `Connector` with `AJP` protocol on port `8009` in `Tomcat`’s `server.xml`. It’s probably available in the 
config file but commented, just uncomment it.

```xml
<Connector port="8009" enableLookups="false" redirectPort="8443" protocol="AJP/1.3" />
```

Download `mod_jk.so` and put it into `modules` directory of `Apache` installation. We need to create and configure 
`workers.properties` file in order to tell `Apache` about target `Tomcat` host and port. There is a full featured and
a minimal `workers.properties` file in source distribution of `mod_jk`. The minimal configuration was enough for us:

```àpache
# The workers that jk should create and work with
worker.list=wlb,jkstatus

# Defining a worker named ajp13w and of type ajp13
# Note that the name and the type do not have to match.
worker.ajp13w.type=ajp13
worker.ajp13w.host=jira.hostname.com
worker.ajp13w.port=8009

# Defining a load balancer
worker.wlb.type=lb
worker.wlb.balance_workers=ajp13w

# Define status worker
worker.jkstatus.type=status
````

Configure `Apache` to load and run `mod_jk` module. It is done inside `httpd.conf` file. However, it is better to put 
those `mod_jk` specific commands into its own conf file and include it into `httpd.conf`. That way becomes easier to 
enable/disable `mod_jk` by just commenting/uncommenting this include line.

Following piece is from inside newly created `httpd-mod_jk.conf` file:

```apache
# Load mod_jk module 
LoadModule jk_module modules/mod_jk.so 
# Where to find workers.properties 
JkWorkersFile E:/work/tools/Apache2.2/mod_jk/workers.properties 
# Where to put jk shared memory 
JkShmFile E:/work/tools/Apache2.2/mod_jk/mod_jk.shm 
# Where to put jk logs 
JkLogFile E:/work/tools/Apache2.2/mod_jk/mod_jk.log 
# Set the jk log level [debug/error/info] 
JkLogLevel info 
# Select the timestamp log format 
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] " 
# Send all requests to worker named wlb 
JkMount /* wlb
```
You can find detailed information about meanings of those commands in the `mod_jk`’s development site. You simply load 
`mod_jk` module, tell `Apache` about place of the `workers.properties` file, and define which requests will be handled 
by defined workers. Here we forward all incoming requests to the `Tomcat` instance. It is possible to restrict which 
requests to be forwarded, and to forward requests to different workers as well.

Following piece is from inside `httpd.conf` file:
```apache
#Tomcat integration 
Include conf/extra/httpd-mod_jk.conf
```
Finally, you just need to restart your `Apache` and `Tomcat` instances for changes to take effect.

