# Enabling Acegi (1)
We have decided to use the [Acegi Security Framework](https://en.wikipedia.org/wiki/Spring_Security) to implement security requirements in our web-based project. However, 
we might possibly have diverse security requirements beyond form-based authentication and role-based authorization. These 
could include remoting support, domain object security, run-as capability, single sign-on (SSO), after-invocation security, 
certificate-based authentication integrated with Active Directory Services, and more.

We will most probably need to customize and modify some of its features, but Acegi definitely provides a good foundation 
for the security architecture of our system. The first step in making a system secure is to decide which authentication 
mechanism to use and the characteristics of the authorization process. One of our requirements is to allow users to 
authenticate themselves via X.509-based client certificates, which will involve enabling SSL communication. These 
certificates will contain distinguished name information, which will be further used to validate their owners against 
Active Directory information. In summary, users will first provide their client certificates and then their Windows domain 
passwords to get authenticated.

Acegi provides a mechanism to implement form-based authentication and allows us to obtain user credentials from any source, 
in our case, X.509 client certificates and the Active Directory Server. Acegi extensively uses filters to make its 
authentication and authorization services work, with each filter having its own particular role in the framework. It 
employs the AuthenticationProcessingFilter to implement HTTP form-based authentication. The AuthenticationProcessingFilter 
comes into play when the request URL is '/j_acegi_security_check'. It then obtains the username and password from the 
request and further asks the AuthenticationManager to authenticate against that information. However, the 
AuthenticationProcessingFilter provided by Acegi does not exactly meet our needs; it attempts to extract the username 
information itself from the request, whereas we want to provide this from our client certificate's distinguished name. 
As a result, we extended the AuthenticationProcessingFilter and modified the part where it obtains the username. Below is 
the modified filter:
```java
public class TbsAuthenticationProcessingFilter extends AuthenticationProcessingFilter {
    protected String obtainUsername(HttpServletRequest request) {
        String username = null;
        X509Certificate cert = getUserCertificate(request);
        if(cert != null) {
            username = cert.getSubjectDN().getName();
        }
        return username;
    }
    private X509Certificate getUserCertificate(HttpServletRequest request) {
        if(request.isSecure()) {
            X509Certificate[] certs = (X509Certificate[]) request.
                getAttribute("javax.servlet.request.X509Certificate");
            if(certs != null) {
                return certs[0];
            }
        }
        return null;
    }
}
```
AuthenticationManager then attempts to authenticate the user, but how? It consults its providers, such as 
PasswordDaoAuthenticationProvider, to determine if they can validate the provided authentication information. 
Unfortunately, the current distribution of Acegi does not include a convenient PasswordAuthenticationDao to connect to 
the Active Directory Server and verify the correctness of the provided username and password information. However, 
thankfully, there exists an [LdapPasswordAuthenticationDao](http://cvs.sourceforge.net/viewcvs.py/acegisecurity/acegisecurity/sandbox/src/main/java/net/sf/acegisecurity/providers/dao/ldap/LdapPasswordAuthenticationDao.java) 
in Acegi's CVS repository, which we are currently utilizing to connect to the Active Directory Server and perform authentication.