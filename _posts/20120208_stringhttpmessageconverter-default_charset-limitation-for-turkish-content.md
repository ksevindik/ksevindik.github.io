# StringHttpMessageConverter DEFAULT_CHARSET Limitation for Turkish Content

Spring has its own REST support known as Spring Web MVC. Although, I am happy with its general capabilities, I came up 
with a small but very annoying problem or, let’s say, a limitation related to one of its `HttpMessageConverter` classes.

Spring Web MVC makes use of `HttpMessageConverter` classes both on the server and client to handle HTTP requests and 
generate responses as well, and one of those converters is `StringHttpMessageConverter`. It is very easy to generate a 
`String` response via this converter and `@ResponseBody` annotation. For example;

```java
@Controller
public class StringResponseBodyTestController {
    @RequestMapping(value="/hello")
    @ResponseBody
    public String hello() {
        return "hello world";
    }
}
```

`StringHttpMessageConverter` looks for the HTTP request’s `Accept` header and tries to extract the `charset` parameter 
out of it. If it can’t, then it uses the `DEFAULT_CHARSET` constant value, which is `ISO-8859-1`. Unfortunately, content 
that has some special Turkish characters won’t display correctly with the default charset.

```java
public String hello() {
    return "hello world - ıİğĞşŞ";
}
```

It is easy to set the `Accept` header value if you are using a REST client utility, e.g., Spring’s `RestTemplate`.

```java
RestTemplate template = new RestTemplate();

HttpHeaders requestHeaders = new HttpHeaders();
requestHeaders.set("Accept", "text/html;charset=utf-8");

HttpEntity<?> requestEntity =
new HttpEntity(requestHeaders);

HttpEntity response = template.exchange(
"http://localhost/hello", HttpMethod.GET,
requestEntity, String.class);

System.out.println(response.getBody());
```

However, if you are trying to access your REST services via a browser, then you will have a problem. Because adding `TR` 
among your preferred languages won’t help, as this causes the `Accept-Language` header to change only. As you see from 
the above example, we need to add the `charset=utf-8` parameter to the `Accept` header. If you are using Firefox, the only 
possible way, as far as I know, is to use an add-on like Modify Headers or HeaderTool.

The bad thing about `StringHttpMessageConverter` is that it doesn’t provide any facility to change this behavior. 
Currently, there are several issues in the Spring JIRA system that ask for a fix or enhancement to this `HttpMessageConverter`.
