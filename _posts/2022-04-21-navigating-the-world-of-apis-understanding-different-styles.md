---
layout: post
title: Navigating the World of APIs, Understanding Different Styles
author: Kenan Sevindik
---

In today's interconnected world, APIs (Application Programming Interfaces) act as crucial **bridges between different services**, 
allowing them to share information and functionality by exchanging messages. These messages adhere to specific 
**protocols and specifications** that define their syntax and semantics. Over time, various **API styles have emerged**, 
each standardizing message exchange in its own unique way. This post will explore some of the most popular API styles 
available, drawing insights from our source material.

## The Landscape of API Styles

The most popular API styles include:

*   Remote Procedure Call (RPC)
*   Simple Object Access Protocol (SOAP)
*   Representational State Transfer (REST)
*   Graphical Query Language (GraphQL)

It's interesting to note that the evolution of API styles has sometimes been framed as "API wars," similar to when 
**REST appeared against SOAP**, and perhaps even earlier with **XML-RPC against RMI or CORBA**. However, the source 
emphasizes that viewing it as a competition with a "one size fits all" approach is problematic. Instead, 
**we should consider how the actual properties and characteristics of each style match the specific situation at hand**.

## Diving into the Styles

Let's take a closer look at each of these API styles:

### RPC: Remote Procedure Call

The primary focus of RPC is **invoking a function on another system**, allowing for the remote execution of a function 
in a different context. Historically, **XML-RPC** appeared first, followed by the simpler **JSON-RPC**, and later **gRPC** 
with added support for features like load balancing, tracing, health checking, and authentication.

**How RPC Works:** A client initiates a remote procedure call by **serializing the parameters and additional information into a message** 
and sending it to a server. Upon receiving the message, the server **deserializes its content, executes the requested operation, and sends a result back to the client**. 
This process is often facilitated by **server and client stubs** that handle the serialization and deserialization.

**Pros of RPC:**

*   Provides **straightforward and simple interaction**, often using methods like GET for fetching data and POST for 
* other operations.
*   It is **easy to add functions**.
*   Allows for **high performance** due to **lightweight payloads**.

**Cons of RPC:**

*   Creates **tight coupling to the underlying system**.
*   **Doesn't allow for an abstraction layer** between the external API and the system's functions.
*   Has **low or no discoverability** due to the **lack of an API introspection mechanism**.
*   May lead to **function explosion**, resulting in a large number of potentially overlapping functions.

**Use Cases for RPC:** RPC is **mostly used internally** for **high-performance, low-overhead messaging**, proving very 
efficient for sending a large volume of messages between services. It's well-suited for **microservices requiring clear and short internal communication** 
and for **direct integration between a single provider and consumer** where there's no need for extensive metadata transmission. 
RPC is also a **proper choice for sending commands to a remote system**, making it a good candidate for creating a **command API**. 
However, it's generally **not considered an option for a strong external API**. If API stability is the primary goal rather 
than high network performance, REST might be a better choice.

### SOAP: Simple Object Access Protocol

SOAP's primary focus is on **making data available as services**. It is an **XML-based and standardized web communication protocol**, 
known for being the **most verbose API style with a massive message structure**. SOAP supports both **stateful and stateless messaging**. 
In a stateful scenario, the server stores received information, which can be resource-intensive but might be necessary 
for complex, multi-party transactions.

**How SOAP Works:** A SOAP message consists of an **envelope**, a **header** for specific requirements, a **body** 
containing the request or response, and a **fault** element for error reporting. The API logic in SOAP is defined using 
the **Web Service Description Language (WSDL)**, which describes endpoints and all performable processes. WSDL facilitates 
quick setup of communication across different programming environments.

**Pros of SOAP:**

*   It is **language and platform agnostic**.
*   A **variety of transport protocols can be used**.
*   It has a **number of security extensions**, integrated with **WS-Security protocols** to provide privacy, integrity, 
* and message-level encryption.

**Cons of SOAP:**

*   It is **XML-only and very heavyweight**.
*   It **requires additional effort** to add or remove message properties.
*   Its **rigid SOAP schema slows down development**.

**Use Cases for SOAP:** SOAP is most commonly used for **integration within and across enterprises and their trusted partners**. 
Its rigid structure, security features, and authorization capabilities make it suitable for **enforcing a formal software contract** 
between API providers and consumers. This is why **financial organizations and other corporate users** often prefer SOAP.

### REST: Representational State Transfer

REST's primary focus is on **making data available as resources**. It's a **self-explanatory API architectural style defined by a set of architectural constraints**. 
REST makes server-side data accessible by **representing it in simple formats**, often **JSON and XML**. Unlike SOAP, 
REST is not as strictly defined.

**How REST Works:** A RESTful architecture should comply with six key architectural constraints:

*   **Uniform Interface:** Allows for a consistent way of interacting with a server, regardless of the device or application.
*   **Stateless:** The server does not store any session-related information; each request contains all necessary details.
*   **Caching:** Permits caching of data on both the client and server sides at the protocol level.
*   **Client-Server Architecture:** Enables independent evolution of the client and server.
*   **Layered System:** Allows for the creation of intermediary layers within the application.
*   **Provide Executable Code (Optional):** The server can provide executable code to the client.

REST is based on **resources (nouns) rather than actions (verbs)**, and operations are performed using **HTTP methods** 
like GET, POST, PUT, DELETE, OPTIONS, and PATCH. A key aspect of mature REST APIs is **HATEOAS (Hypertext As The Engine Of Application State)**, 
which involves providing metadata linking to related information about how to use the API, enabling decoupling and self-discoverability. 
While HATEOAS is considered the most mature form of REST, it is not always implemented and can be complex for clients. 
Many APIs adopt a more basic form of REST, sometimes referred to as HTTP RPC, by breaking down services into resources 
and efficiently using HTTP infrastructure.

**Pros of REST:**

*   **Decoupled Client & Server:** Allows for better abstraction and modeling, making the API flexible for evolution.
*   **Discoverability:** HATEOAS eliminates the need for external documentation to understand how to interact with the API.
*   **Cache-friendly:** REST is the only style that inherently supports caching at the HTTP level.
*   **Supports multiple formats:** Including JSON, XML, and HTML.

**Cons of REST:**

*   **No single REST structure:** Modeling resources can be scenario-dependent, making it simple in theory but potentially difficult in practice.
*   **Big payloads:** Responses can contain a lot of metadata, which might be unnecessary for internal communication.
*   **Over- and under-fetching problems:** Responses might contain too much or too little data, often necessitating additional requests.

**Use Cases for REST:** REST APIs are most commonly used for **managing objects in a system and are intended for many consumers**. 
It's a valuable approach for **connecting resource-driven services that don't require flexibility in queries**. While REST 
can be heavier and chattier than RPC, it is a dominant style for many public-facing APIs.

### GraphQL

GraphQL's primary focus is on **querying just the needed data**. It is a **syntax that describes how to make precise data requests**, 
essentially a querying language for APIs.

**How GraphQL Works:** GraphQL begins with **building a schema**, which describes all possible queries and the types they 
return. When a GraphQL operation reaches the backend, it is interpreted against this schema and resolved with data for 
the frontend application. The API then returns a **JSON response containing exactly the data requested**.

**Pros of GraphQL:**

*   **Typed schema:** GraphQL clearly defines its capabilities in advance, improving **discoverability** by allowing 
*   **Fits graph-like data very well:** It excels at handling data with deep and linked relations.
*   **No versioning:** The best practice is to avoid API versioning altogether with GraphQL.

**Cons of GraphQL:**

*   **Performance issues:** Highly nested queries can potentially overload the system.
*   **Caching complexity:** GraphQL doesn't reuse HTTP caching semantics, requiring custom caching implementations.

**Use Cases for GraphQL:** GraphQL is particularly well-suited for **mobile APIs** where network performance and minimizing 
payload size are crucial, offering more efficient data loading. It's also beneficial for **complex systems and microservices**, 
as it can **hide the complexity of integrating multiple systems** behind a unified API by aggregating data from various 
sources into a single schema.

## Quick Summary

To provide a concise overview, here's a summary of the key aspects of each API style:

|                     | RPC                                       | SOAP                                                 | REST                                                                 | GraphQL                                     |
| :------------------ | :---------------------------------------- | :--------------------------------------------------- | :------------------------------------------------------------------- | :------------------------------------------ |
| **Primary Focus**   | Invoking functions on another system       | Making data available as services                    | Making data available as resources                                   | Querying just the needed data             |
| **Best at…**        | ● Internal, direct, high-performance communication <br> ● Making command API | ● Integrating different enterprises and their partners <br> ● Enforcing a strict software contract | ● Developing management APIs <br> ● Connecting resource-driven services that don’t require query flexibility | ● Querying deep and complex graph-like data structures <br> ● Aggregating data from multiple backend services |

## Conclusion

As we've explored, each API style has its own strengths and weaknesses, making it suitable for different scenarios. 
The choice of API style should not be based on trends or a "one-size-fits-all" mentality. Instead, a careful evaluation 
of the specific requirements, such as performance needs, security considerations, integration complexity, and the intended 
audience of the API, is essential to selecting the most appropriate style. Understanding the characteristics of RPC, SOAP, 
REST, and GraphQL empowers developers and architects to make informed decisions and build effective and efficient 
communication pathways between services.