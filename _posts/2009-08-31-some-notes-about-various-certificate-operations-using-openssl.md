# Some Notes About Various Certificate Operations Using OpenSSL

Our system support group delivered a signed certificate to be used in `Apache` SSL configuration. Its extension was 
`*.pfx`, which meant its contents were in `PKCS12` format, and was containing both `certificate` and its `private key` 
in it. I needed to convert it into `PEM` format and to separate `certificate` from its `private key`.

The first command creates `key` file, and the second one converts `certificate` into `PEM` format;

```bash
openssl pkcs12 -in innova.pfx -nocerts -nodes -out innova.key 
openssl pkcs12 -in innova.pfx -clcerts -nokeys -out innova.pem
```

I needed to create a `CA cert list` which will contain `CA certificates` appended to one another. `CA certificates` of 
our signed `certificate` were delivered in binary `DER` format. In order to create appended `cert file` in `PEM` format, 
I first needed to convert those binary `CA certs` into `base64` encoded format. This is easy with “`Certificate Export Wizard`” 
in `Win32` platform. You just need to open `certificate` and save it to `file` and select the format during this process. 
After that, I issued following command to create appended `CA cert list` in `PEM` format.

```bash
openssl x509 –in ca1.cer –text >> ca_cert_list.pem
```

I needed to repeat above command for each `CA cert` separately.

```bash
openssl x509 –text –in innova.pem
```

In order to see `CN` (common name) specified in your `certificate`;
Above command will output `cert info` in textual form. If your `certificate’s CN` looks similar to 
“`CN=\x00*\x00.\x00i\x00n\x00n\x00o\x00v\x00a\x00.\x00c\x00o\x00m\x00.\x00t\x00r`”, don’t think that it is corrupted or 
so. If it is a `wildcard certificate`, that is issued for all `*.innova.com.tr` subdomains as in our example, outputing 
`CN` will be shown as above.

If your `certificate’s format` is `PKCS12` then you must use;

```bash
openssl pkcs12 -info -in innova.pfx
```

Here, you will be prompted `key passphrase`, and asked a new `PEM passphrase` as well. Second `passphrase` is not 
important as we only display `certificate structure` in standard output.
