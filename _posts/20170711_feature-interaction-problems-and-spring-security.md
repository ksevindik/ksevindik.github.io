# Feature Interaction Problems and Spring Security

Feature interaction problem is something that features work smoothly and without any problem in your system individually; 
however, problems arise with those features when you bring them together. Bertrand Meyer has recently 
[published](https://bertrandmeyer.com/2017/06/19/perils-feature-interaction/) his thoughts about the topic as well. 
While reading on it, I’ve come to realize that Spring Security has several similar issues which arise whenever we attempt 
to configure those features to work together in our system.

One example of feature interaction problem in Spring Security arises between the **digest authentication** feature and 
keeping passwords encrypted in your database. `DigestAuthenticationFilter` is used to authenticate users through an 
insecure HTTP channel by sending a digested form of user credentials. The server side of digest authentication needs to 
look up the user realm, obtain the user and her credentials, and then generate a digested form in order to compare it 
with the one sent by the client. Therefore, user credentials must be kept in plain text form in the user realm. However, 
it is highly important to store user passwords in an encrypted form within the database so that nobody, even DB admins, 
can obtain any user’s secret password by querying the database itself. Spring Security also provides us with a 
`PasswordEncoder` to encode user-submitted raw passwords prior to comparing them against the encoded ones obtained from 
the database. At this point, we are at a crossroad: we have to either choose to use `PasswordEncoder` and keep credentials 
encoded in the database, hence give up the digest authentication mechanism, or choose to use digest authentication and 
compromise keeping passwords in a secure form.

The other example is between **switch user** and re-authenticating an already authenticated user before allowing her to 
access any web resource. `SwitchUserFilter` inspects a special URL to obtain the username to which the current authentication 
is to be switched. When such a request arrives, it extracts the username and queries the user realm via `UserDetailsService` 
to obtain the corresponding `UserDetails` info from the database. As a result, a new authentication token with the new 
`UserDetails` object is created and put into the `SecurityContext`. Afterwards, the request is redirected to a success URL. 
At this point, `FilterSecurityInterceptor` triggers a re-authentication process for the redirected success URL. It delegates 
the authentication process to `AuthenticationManager` and `DaoAuthenticationProvider` in the end. `DaoAuthenticationProvider` 
loads one `UserDetails` from the user realm, obtains the other from the current authentication token, and then starts 
comparing their credentials. If `DaoAuthenticationProvider` is configured to work with `PasswordEncoder`, it tries to 
encrypt the user password obtained through the current authentication prior to comparing it with the one obtained from 
the database during re-authentication. However, as `SwitchUserFilter` has also loaded `UserDetails` from the same database, 
it also has an encrypted password value in it. Therefore, applying the password encoding process a second time causes the 
password comparison to fail, even though the `UserDetails` objects fetched from the database and obtained from the current 
authentication token are the same. Again, you have to either give up the switch user feature or store passwords in raw 
form in the database.

The above two examples are very nice sample cases for the perils of feature interaction, and how hard it may become to 
introduce new features in any kind of software system over time as they might cause conflicts with the already existing ones.
