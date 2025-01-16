# Enabling SSL on Apache HTTP Server

After opening our JIRA to outside world via Apache HTTP Server, the next obvious thing was securing communication between
users and the web server. Enabling SSL on Apache HTTP Server is really easy. The key ingredients of securing Apache are
`mod_ssl` and `OpenSSL`. It is possible to download Apache distribution including `mod_ssl` and `openssl` runtime.

Here are the steps to enable SSL on Apache:

Copy `mod_ssl.so` into the `modules` directory, and add the following line to your `httpd.conf` file. If you have
downloaded Apache distribution with SSL, they are already available. You only need to uncomment that line.

```apache
LoadModule ssl_module modules/mod_ssl.so
```

Uncomment the following line in your `httpd.conf` file as well.

```apache
Include conf/extra/httpd-ssl.conf
```

In order to enable SSL, we need to provide a X509 certificate for server identification. For testing purposes you can
create a self-signed certificate and install it to start using Apache securely, however your users will see a security
warning, which says your certificate is not trusted. In order to clear this warning you need a certificate created by
a trusted certificate authority (CA). Nowadays, you don’t have to pay for a certificate for server identification.
There are several sites which provide you with free certificates. However, you must be ready to pay for extra features
you need from the certificate.

## Creating a self-signed certificate for testing purposes

First, we need to create a private/public key pair which will be used during certificate creation. In order to do this,
we need `openssl`. In Apache bin directory, execute the following command:

```bash
openssl genrsa -des3 -out ..\conf\server.key 1024
```

This will generate a public/private key pair with triple DES algorithm, having 1024 bits in the private key. During key
generation, `openssl` will ask a passphrase in order to secure access to the private key. The private key is kept encrypted
and this passphrase is required to access it. Then, we need to issue the following command to create a self-signed
certificate with the above key pair:

```bash
openssl req -config ..\conf\openssl.cnf -new -key ..\conf\server.key -x509 -out ..\conf\server.crt
```

On the Win32 platform, we get an error related to accessing `openssl.cnf` file. Therefore we give its path with the `-config`
parameter. The req `-new` command is normally used to issue a new certificate request, but the `-x509` option causes an x509
structure to be output instead of a new request. If you create `server.key` and `server.crt` with different names and in a
different folder other than conf, you will need to change related directives in the `httpd-ssl.conf` file:

```apache
SSLCertificateFile "E:/work/tools/Apache2.2/conf/server.crt"
SSLCertificateKeyFile "E:/work/tools/Apache2.2/conf/server.key"
```

During startup, Apache will require a passphrase assigned to the private key. In httpd-ssl.conf, the SSLPassPhraseDialog
builtin directive causes Apache to pop a dialog to enter this passphrase. Unfortunately, the built-in dialog doesn’t work
on the Win32 platform. Instead, we can create an executable script to provide it and change the directive to specify the
path of this executable script as follows:

Put the following line into the conf\passphrase.bat file to echo the passphrase.

```batch
@echo secret
```

```àpache
SSLPassPhraseDialog exec: E:/work/tools/Apache2.2/conf/passphrase.bat
```

It is a vulnerability to leave the passphrase in such a text file on a machine, accessible from the outside world. You
must immediately remove the echo statement from the `passphrase.bat` file after the Apache server starts.

## Creating and configuring a certificate signed by a trusted certificate authority
In order to have a certificate signed by a CA, we first need to create a certificate request.

```bash
openssl req -config ..\conf\openssl.cnf -new -key ..\conf\server.key -out ..\conf\server.csr
```

Next, we need to submit it to our CA, and wait to receive the signed certificate from it. CAs usually provide detailed
information about how to submit requests, receive and save signed certificates, etc. Let me assume that the signed
certificate is already saved into the filesystem. You need to give its path to the `SSLCertificateFile` directive if it's
different than `conf\server.crt`.

It is also necessary to put the certificate chain into a PEM encoded file and point it with the `SSLCertificateChainFile`
directive in `httpd-ssl.conf`. The certificate chain usually is composed of more than one CA. This PEM encoded file keeps
all of those CA certificates appended to each other.