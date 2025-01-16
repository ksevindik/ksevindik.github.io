# Configuring Vaadin without web.xml

There is always room for improvement in programming world. After my [initial post](http://www.kenansevindik.com/how-to-start-working-with-vaadin/) 
about configuring Vaadin in 6 simple steps, one of my friends indicated that we could have used annotation based 
configuration to get rid of web.xml in our Vaadin configuration. Yes, he is right. It is possible to configure Vaadin 
with annotations without touching web.xml at all. Let’s see how it can be achieved;

## Step 1: Add Servlet API dependency into your pom.xml, and update your project’s configuration

```xml
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>3.1.0</version>
    <scope>provided</scope>
</dependency>
```

## Step 2: Modify your HelloWorldUI as follows

```java
public class HelloWorldUI extends UI {
	
	@WebServlet(urlPatterns={"/*"},asyncSupported=true)
	@VaadinServletConfiguration(ui=HelloWorldUI.class,productionMode=false)
	public static class ExtendedVaadinServlet extends VaadinServlet {
	}

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

## Step 3: Remove or comment out VaadinServlet configuration in web.xml

Just remove <servlet> and <servlet-mapping> elements in web.xml we had added in our previous post. Now restart your web 
container, and try to access http://localhost:8080/helloworld URL in your local environment to see the result. It should 
work without any problem as before.