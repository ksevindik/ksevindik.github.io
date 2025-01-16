# How to Start Working with Vaadin

We are highly satisfied with Vaadin UI Framework in our enterprise Java projects. I recommend it to anyone who are asking 
advice about what UI framework to use in their enterprise web applications. This article, however, is not about why we 
like Vaadin. It might be a topic for another article. I will try to show, in this article, how to start working with 
Vaadin from ground zero super fast. I decided to write about this topic after a message from one of my friends complaining 
about difficulty in finding his way through Vaadin Book and expressing his confusion about whether using any Vaadin plugin 
or IDE support is a must to start working with Vaadin.

Let’s start with step by step.

## Step 1: Create a web project using maven webapp archetype

```shell
mvn archetype:generate -DgroupId=com.example.vaadin -DartifactId=helloworld -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false
```

## Step 2: Import the project into your favorite IDE

I prefer to use Eclipse as IDE, but it should not matter whether you use IntelliJ or Netbeans either. Just import the 
maven project you created in the first step. The project should be ready to use within your favourite IDE after the import.

## Step 3: Add Vaadin Dependencies into pom.xml of your project

Add following dependencies into pom.xml file of the project.

```xml
<dependency>
    <groupId>com.vaadin</groupId>
    <artifactId>vaadin-server</artifactId>
    <version>7.6.4</version>
</dependency>

<dependency>
    <groupId>com.vaadin</groupId>
    <artifactId>vaadin-client-compiled</artifactId>
    <version>7.6.4</version>
</dependency>

<dependency>
    <groupId>com.vaadin</groupId>
    <artifactId>vaadin-themes</artifactId>
    <version>7.6.4</version>
</dependency>
```

## Step 4: Write a UI class in your project

Create a new package with name com.example.vaadin, and following class beneath that package.

```java
package com.example.vaadin;
import com.vaadin.server.VaadinRequest;
import com.vaadin.ui.Button;
import com.vaadin.ui.Button.ClickEvent;
import com.vaadin.ui.Button.ClickListener;
import com.vaadin.ui.Notification;
import com.vaadin.ui.UI;

public class HelloWorldUI extends UI {
	protected void init(VaadinRequest request) {
		Button btn = new Button("Click Me!");
		btn.addClickListener(new ClickListener() {
			public void buttonclick(ClickEvent event) {
				Notification.show("Hello World!");
			}
		});
		setContent(btn);
	}
}
```

## Step 5: Configure web.xml file of your project by adding following part into it

```xml
<servlet>
    <servlet-name>VaadinServlet</servlet-name>
    <servlet-class>com.vaadin.server.VaadinServlet</servlet-class>
    <init-param>
        <param-name>UI</param-name>
        <param-value>com.example.vaadin.HelloWorldUI</param-value>
    </init-param>
</servlet>

<servlet-mapping>
    <servlet-name>VaadinServlet</servlet-name>
    <url-pattern>/*</url-pattern>
</servlet-mapping>
```

## Step 6: Deploy the project into web container and start it
Now you can deploy your project into web container configured in your IDE. I prefer tomcat, but It doesn’t differ if you 
choose jetty or something else. Just type the url your application deployed in the container, e.g. http://localhost:8080/helloworld, 
and you should have seen the “Click Me!” button on the page.

Keep in mind that above steps are not enough to leverage all the features of Vaadin, however, it is sufficient enough to 
start working with Vaadin, and develop your server side UI components from that part. You can add necessary pieces into 
your project once you need them, and it should be easier to add those pieces as you get more comfortable within the Vaadin 
ecosystem.
