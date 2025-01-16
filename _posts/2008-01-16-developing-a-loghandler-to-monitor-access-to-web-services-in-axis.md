# Developing A LogHandler To Monitor Access To Web Services in Axis
We need to monitor access (from where, who, etc.) to our web services, trace incoming and outgoing message contents for 
auditing purposes. It is better to separate this task from web services themselves and let the web service infrastructure, 
which is Axis in our case, handle this operation.

In Axis, it is possible to develop custom `Handler` objects and register them to service requests and responses so that 
we can easily extract necessary information from message requests and get SOAP message body to collect necessary auditing 
data. Axis provides `org.apache.axis.Handler` interface and a `BasicHandler` abstract class as a convenience class for 
custom `Handler` classes.

```java
public class LogHandler extends BasicHandler {
	public void invoke(MessageContext messageContext) throws AxisFault {
	}
}
```

The `invoke` method is called whenever a request comes in and a response goes out from the web service for which a custom 
`Handler` is configured. In our case, we use HTTP transport mechanism to expose our web services using Servlets; therefore, 
we expect to get HTTP requests. The question here is how to access `HttpServletRequest` within those `Handler` objects. 
Axis puts the current request object into `messageContext` as a property (`transport.http.servletRequest`) and you can 
access any available property by just calling `messageContext.getProperty(name)` method.

```java
public class LogHandler extends BasicHandler {
	public void invoke(MessageContext messageContext) throws AxisFault {
		HttpServletRequest request = (HttpServletRequest) messageContext.getProperty("transport.http.servletRequest");
	//...
	}
}
```

We also want to log SOAP message requests and responses. As our `LogHandler` object is called for both requests and 
responses, we need a way to understand whether it is called at request time or at response time. Axis has a “pivot point” 
concept. Basically, it is the point at which a request is processed and a response is produced, or a new request is sent 
and a response is received. Web service providers such as `RPCProvider` and `MsgProvider` types are pivot points for all 
RPC services and messaging services respectively. `MessageContext` class provides an API to check if the current request 
has passed a pivot point, that is, it is processed and a response is produced, or not.

```java
public class LogHandler extends BasicHandler {
	public void invoke(MessageContext messageContext) throws AxisFault {
		if (!messageContext.getPastPivot()) {
			//get message request from context and do related task...
		} else {
			//get message response from context and do related task...
		}
	}
}
```

Another point in our `LogHandler` is to log exceptions occurred during web service request handling. The `invoke` method 
is not called for SOAP faults. There is an `onFault()` method which is for this purpose. It is already implemented in 
`BasicHandler`; therefore, you need to override it in your `Handler` class and perform your specific task when a SOAP 
fault occurs.

```java
public void onFault(MessageContext messageContext) {
	//get message response from context and do related task...
}
```

Axis architecture is all about processing messages, and during that processing, a series of `Handler` objects can be 
invoked to intercept that message processing. You can easily create a chain of message Handlers as well.
