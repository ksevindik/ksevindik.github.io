# Things to Fix When Upgrading from Spring Security 3.2.x to 4.x

Some things have been changed in Spring Security 4.x compared to previous 3.2.x branches. They are not overwhelming but 
you may have to deal with them so that your application can work without any problem after upgrading to Spring 4.x 
release. I noted them down during my upgrade process, and post here in case you need.

* For a long time, the login processing URL, username, and password request parameter names of `UsernamePasswordAuthenticationFilter` 
were `j_spring_security_check`, `j_username`, and `j_password` consecutively. They are now replaced with `login`, 
`username`, and `password` by default.

* The CSRF protection feature has been available for some time, but it was disabled by default. However, Spring Security 
4.x comes with CSRF protection enabled by default. This change has consequences for your web requests, especially pages 
that perform form submission with the HTTP POST method. You need to add an hidden input parameter as following;

```html
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
```

* The `<http>` element had `use-expressions="false"` in the Spring 3.2.x series. Therefore, `<intercept-url>` elements were 
usually being configured with `ROLE_xxx` access attributes by default. This has changed in Spring 4.x as well. From now 
on, Spring Security expressions are active by default, and anyone who starts using Spring Security should provide 
`intercept-url` access attributes with expressions returning a boolean value.

* The logout processing URL has also been changed to `logout` from `spring_security_logout`. `LogoutFilter` is now only 
accepting POST requests. Therefore, you need to add a simple logout form which is calling logout with HTTP POST method.

```html
<form action="logout" method="post">

    <input type="submit" value="Logout"> 

    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

</form>
```

However, it is not currently possible to change the configuration of `LogoutFilter` so that it works with HTTP GET requests.

* `RememberMeAuthenticationFilter` was querying the `_spring_security_remember_me` request parameter to initiate the 
remember-me mechanism. This has changed to `remember-me` in Spring 4.x.

* Some classes in `acl` packages were also changed. Therefore, you may need to change your `acl` bean configuration if you 
are using ACL in your project.
