# How to keep hackers informed about your users!?
Application developers usually tend to be as specific as possible when providing information about unexpected errors that 
occur during runtime. Most of the time, this approach is good, but it may not be suitable for all use cases. The user login 
scenario is one of those exceptions. When a user provides insufficient or invalid credentials, or when a user account is 
inaccessible due to some other reason, the application shouldn’t reveal more information than necessary. For instance, it 
shouldn't disclose that the user isn’t allowed to login because of invalid or insufficient credentials, as this might expose 
too much information about the user's current status. Let’s examine the following code example:

```java
UserDetails userDetails = userDAO.findUserByUsername(username);
if(userDetails == null) {
    throw new UserNotFoundException();
} else if(!userDetails.getPassword().equals(password)) {
    throw new InvalidCredentialsException();
} else if(userDetails.isRevoked()) {
    throw new UserRevokedException();
} else {
   return userDetails;
}
```

The above code block attempts to identify possible causes of unsuccessful authentication attempts in detail. However, it's 
important that these identified causes aren’t surfaced to the GUI with error messages such as `"You cannot login. Username not found."`, 
`"You cannot login. Invalid password."`, or `"You cannot login. User revoked."`, as such descriptive messages could provide 
valuable information to a hacker attempting to exploit vulnerabilities in your system. Instead, a generic message like 
`"Unsuccessful login attempt. Invalid username or password."` should suffice.

Many application developers fall into the trap of revealing too much information due to a lack of knowledge about application 
security concepts. They often confuse business exceptions with unexpected program errors and aim to provide users with as much 
information as possible to assist them in identifying what went wrong at runtime. In our case, catching a general 
`AuthenticationException` at the presentation level and displaying the less specific `"unsuccessful login attempt"` 
message is the recommended approach.


