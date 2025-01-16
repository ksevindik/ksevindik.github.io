# Spring Boot & JSPs in Executable JARs
Nowadays, almost everyone employs their favorite JS-based framework while developing their dynamic web applications. 
There are dozens of client- and server-side UI frameworks around, and you can be sure that you are going to be criticized 
for your choice no matter which one you choose. Some will ask why it is not Angular, and others will ask why it is Angular. 
We also employ the Vaadin UI Framework in our projects. However, I still prefer not to employ any of those frameworks 
during the trainings I give over `java-egitimleri.com`. My choice is still JSP in order to teach the fundamentals of web 
application development to my audience. I have some reasons for this:

- It is a lot easier to demonstrate the building blocks of Web MVC architecture and explain how the front controller pattern works.
- You don’t need any third-party dependency or any pre-configuration to make them run.
- They can be modified easily at runtime without requiring any recompilation or server restart.

My aim is not to deal with various UI gadgetry, but instead focus more on the backend process of developing enterprise 
web applications during my trainings.

Trainings mostly contain Spring stuff, and Spring Boot is the framework/platform to melt down all those Spring, JPA/Hibernate, 
and various middleware-related theories into an executable and demonstrable artifact easily. However, Spring Boot doesn’t 
play nicely with JSPs in executable JAR format. They ask you either to switch to the executable WAR format and not use 
Undertow as a web container, or employ another templating engine, such as Thymeleaf or FreeMarker.

Anyway, I was okay with switching into WAR packaging, creating the `src/main/webapp` folder to place all those JSPs and 
their static resources underneath, and keeping up with embedded Tomcat. However, a few days ago, I questioned myself again 
if there might be an alternative way to keep all those JSP and related stuff under `src/main/resources`, and I came up 
with a little but invaluable information around the web. According to JSR-245 and Servlet 3.0 API, it is possible to place 
static resources within the `/META-INF/resources` folder of JAR files. This means that we can move our JSPs and their 
related static content into the `/src/main/resources/META-INF/resources` folder in our Spring Boot projects!

I tried it immediately, and it worked without any problem inside my STS IDE. Afterwards, I decided to create an executable 
JAR and check if everything still works there as well. Unfortunately, it doesn’t!

When I extracted the executable JAR file, I noticed that the Spring Boot Maven Plugin repackaged the JAR content by moving 
everything under the `/BOOT-INF/classes` folder, including `/META-INF/resources`. Unfortunately, the Spring Boot Maven 
Plugin has no way to specify excludes during repackaging.

The only viable solution is to create another simple Maven project containing your JSPs and their related static content 
under `src/main/resources/META-INF/resources`, and make it a dependency of your Spring Boot project. This might look a 
bit weird to some of you, but this seems like the only viable workaround to this repackaging issue with the plugin, as 
the developers responsible for the Spring Maven Plugin respond by suggesting moving to Gradle in case you are blocked 
with Maven. 🙂
