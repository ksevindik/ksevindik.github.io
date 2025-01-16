# Error while generating JAXB Classes from XSD File

You may get following error when you try to generate JAXB classes from your XSD files within Eclipse IDE.

```console
Error: Could not find or load main class com.sun.tools.internal.xjc.XJCFacade
```

The reason for this error is that you have configured Eclipse to use JRE instead of JDK. If you add a JDK through 
Window>Preferences>Java>Installed JREs, and select it as the active JRE, you will probably get rid of this error.

PS. In some situations, which I haven’t fully understand yet, Eclipse insists on using other JRE/JDK configuration other 
than my current selection. If your error persists after adding JDK, try removing other JRE entries from Installed JREs.