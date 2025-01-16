# If Your Eclipse Hangs...

Recently, my STS installation started to freeze during “initializing java/spring tooling” step. As a first attempt, I 
suspended all validations from window>preferences>validation, however it didn’t help much. Whenever you experience a hang 
or freeze in your Eclipse installation, it is always a good habit to look inside of .metadata/.log file in Eclipse 
workspace folder. Most of the time, causes for such hangs or freezes appear to be network problems. I was right, this 
time it was no exception, either. I noticed “Connection timeout” messages in the log file. In order to discover the URL 
address which causes connection timeout, I switched off wireless connection of my laptop and restarted STS. This time 
messages turned into “unknown host exception” indicating java.sun.com. I thought I am on the right track. I guessed somehow 
there was a connectivity problem with java.sun.com. The last step was to add a line in my /etc/hosts file so that 
java.sun.com request will resolve into my machine instead of going through Internet. After adding that line, and restarting 
STS again, error messages turned into FileNotFoundExceptions pointing URI http://java.sun.com/dtd/web-app_2_3.dtd. 
Exception stacktrace was self explanatory, the problem was related with Spring tooling auto config detection.

```stacktrace
!MESSAGE java.io.FileNotFoundException: http://java.sun.com/dtd/web-app_2_3.dtd
!STACK 0
java.lang.RuntimeException: java.io.FileNotFoundException: http://java.sun.com/dtd/web-app_2_3.dtd
at org.springframework.ide.eclipse.core.SpringCoreUtils.parseDocument(SpringCoreUtils.java:650)
at org.springframework.ide.eclipse.core.SpringCoreUtils.parseDocument(SpringCoreUtils.java:627)
at com.springsource.sts.ide.metadata.locate.DynamicWebProjectBeansConfigLocator.canLocateInProject(DynamicWebProjectBeansConfigLocator.java:239)
at org.springframework.ide.eclipse.beans.core.model.locate.AbstractPathMatchingBeansConfigLocator.locateBeansConfigs(AbstractPathMatchingBeansConfigLocator.java:67)
```

