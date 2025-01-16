# Enabling SSL with Client Authentication in Tomcat
It is very common to enable SSL only with server authentication, because it is required by the SSL specification. However, 
it is not as common to activate client authentication, as it is optional.

Enabling SSL is a server-dependent process. First, I will give a rough overview of this process step by step and then 
explain each one in detail with examples using Tomcat.

1. Configure the Connector definition in the `server.xml` file of Tomcat.
2. Create a certificate with the alias `tomcat` for server authentication and place it in a keystore that will be accessed by Tomcat.
3. Create a trust keystore that will be used to keep trusted certificate entries which will be used during client authentication.
4. Create a client certificate that will be used for client authentication.

That’s all! It is time to now go over each step in detail.

As a first step, we have to configure the Connector definition in the `server.xml` file. By default, the `server.xml` 
file contains a Connector definition for SSL, but it is commented out, and we need to add some other attributes to it. 
We can start by commenting out that connector definition.
```xml
<Connector port="8443" 
       maxThreads="150" minSpareThreads="25" maxSpareThreads="75"
       enableLookups="false" disableUploadTimeout="true"
       acceptCount="100" debug="0" scheme="https" secure="true"
       clientAuth="true" sslProtocol="TLS" />
```
We have to set the `clientAuth` attribute's value to `true` to enable client authentication; otherwise, our server will 
not request a client certificate. Then, we specify the location of our keystore file, in which our server's certificate 
will be kept, and its password.
```xml
keystoreFile=”/keystores/server.keystore”    keystorePass=”secret”
```
By default, Tomcat looks for the server certificate in a keystore that is in the user's home directory with the default 
password “**changeit**”.

In addition to specifying the keystore location for the server certificate, we also need to specify to Tomcat where to 
look for validating client certificates.
```xml
truststoreFile=”/keystores/trust.keystore”
```
We can use the same password for both of the keystore files, and specifying only one is enough. Providing `truststoreFile` 
in the connector definition is important; otherwise, Internet Explorer will not be able to display available certificates 
that can be used for client authentication.

The second step is creating necessary certificates for both the server and the client. We need a trusted certificate 
authority to create and validate those certificates. I used Microsoft Certification Authority for this step. It is also 
possible to create a self-signed server certificate using Java keytool and use it in server authentication, but for client 
authentication, we need to create a personal client certificate, and this is not possible with keytool.
We can download the CA certificate from MS Certification Authority via its web interface and then install it in our trust 
and server keystores. For example, let's say `ca.cer` is our downloaded CA certificate file;
```terminal
keytool –import –trustcacerts –alias ca –file ca.cer –keystore /keystores/server.keystore –storepass secret
keytool –import –trustcacerts –alias ca –file ca.cer –keystore /keystores/trust.keystore –storepass secret

keytool –genkey –alias tomcat –keystore /keystores/server.keystore –storepass secret
```
This will generate a public-private key pair that will be used for server authentication. It is important to make the key 
and keystore passwords the same; otherwise, Tomcat will not be able to access the certificate. Later, we create a 
certification request using this generated key pair.
```terminal
keytool –certreq –alias tomcat –file /keystores/tomcat.req –keystore /keystores/server.keystore –storepass secret
```

We use this certification request to create a certificate from the Certification Authority, again via its web interface. 
When our certificate is ready, we need to import it into our keystore. Let's say our generated certificate is in the 
file `tomcat.cer`;
```terminal
keytool –import –alias tomcat –file /keystore/tomcat.cer –keystore /keystores/server.keystore –storepass secret
```
Imports certificate that will be used for server authentication.

We also need to create a client certificate that will be used to authenticate our client/user. We create it via the 
Certification Authority. We make a certification request. When the CA issues a certificate for us, we need to install it 
using Internet Explorer, accessing through the web interface of the Certification Authority. Internet Explorer keeps our 
client certificate's private key in a safe place, that is local to our client's machine, so this certificate will only 
work from our client's machine from which we make the certification request.

One important key note here: Internet Explorer will not display the client certificate selection dialog if there is no 
valid or there is only one valid client certificate installed on the client machine. If we want to display this dialog, 
even for those cases, we need to configure it using the **Internet Options > Security Settings** window, by disabling 
“**Don’t prompt for client certificate selection when no certificates or only one certificate exists**”. Internet Explorer 
determines valid client certificates via Tomcat's trusted certificate located in the trust keystore. If we don’t provide 
a trust keystore for Tomcat, Internet Explorer will not be able to show our valid client certificates in its certificate 
selection dialog.

Finally, it is time to give a try to our SSL configuration: [https://localhost:8443](https://localhost:8443).
