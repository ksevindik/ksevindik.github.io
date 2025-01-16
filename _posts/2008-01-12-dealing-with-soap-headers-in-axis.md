# Dealing with SOAP Headers in Axis
After a long period, I have returned to working with `Axis` to develop web services. `Axis` 1.4 is a framework for 
creating SOAP processing clients and servers. One of the issues I encountered during my web service development is dealing 
with SOAP headers.

You can use SOAP header elements to send application-specific information (e.g., authentication, context, time, etc.) 
about SOAP messages. Although they are optional, there is an attribute called `mustUnderstand` in `SOAPHeaderElement`. 
Once it is set to true, the actor who receives the SOAP message must process it correctly.

You must deal with this attribute or SOAP Header in order to successfully process your SOAP message; otherwise, you will 
get a SOAP fault. There are several alternatives for dealing with this. You can either set this flag to false again or 
remove the `SOAPHeaderElement` from the message envelope inside your custom `Axis` handlers. For example:

```java
public class SoapHeaderConsumerHandler extends BasicHandler {
	public void invoke(MessageContext messageContext) throws AxisFault {
		try {
			SOAPHeader soapHeader = (SOAPHeader) messageContext.getMessage().getSOAPHeader();
			Iterator itr = soapHeader.examineAllHeaderElements();
			while (itr.hasNext()) {
				SOAPHeaderElement element = (SOAPHeaderElement) itr.next();
				element.setMustUnderstand(false)
			}
		} catch (SOAPException e) {
			throw new RuntimeException(e);
		}
	}
}
```

The other alternative is to extract them from the message envelope. `Axis` `SOAPHeader` provides methods to extract all 
header elements or to extract ones that belong to a specific actor.

```java
SOAPHeader soapHeader = (SOAPHeader) messageContext. getMessage().getSOAPHeader();
Iterator itr = soapHeader.extractAllHeaderElements();
```
When you call the extract method, you will get an iterator to iterate over `SOAPHeaderElements` that are removed from the 
message envelope.

You can configure your custom handler in `Axis` at different levels. They can be configured globally or be made specific 
to several services. It is also possible to invoke them just for requests or responses or both. `Axis` uses a web service 
deployment descriptor (`wsdd`) to keep all this configuration information. More info about Handlers is coming in the next 
post…
