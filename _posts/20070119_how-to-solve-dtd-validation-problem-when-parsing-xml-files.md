# How to Solve DTD Validation Problem When Parsing XML Files
I think many people, including myself, mistakenly assume that setting the validation feature of an XML parser to `false` 
is sufficient to prevent exceptions when the DTD specified in an XML file is inaccessible. However, this is not the case. 
Even if validation is not requested, the XML parser still requires access to the DTD to expand any entity references. 
This misconception likely arises because DTDs are commonly associated with validating XML files. To avoid issues with 
inaccessible DTDs, you must either remove the DTD reference from the file before parsing or create a custom `EntityResolver` 
to handle entity reference requests. The following approach will not work for parsing XML files with inaccessible DTDs:

```java
parser.setFeature("http://xml.org/sax/features/validation",true);
```

And here is a solution to the problem, involving the definition of a custom `EntityResolver` and configuring it with 
the parser:

```java
public class HibernateMappingDTDEntityResolver implements EntityResolver {
     private InputSource source;     
     HibernateMappingDTDEntityResolver () throws SAXException {
         Resource dtd = new ClassPathResource("org/hibernate/hibernate-mapping-3.0.dtd");
         try {
             source = new InputSource(dtd.getInputStream());         
         } catch (IOException e) {
             throw new SAXException(e);         
         }    
    }     

    public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
          return source;     
    } 
}
```

...

```java
Resource xmlFileResource = new ClassPathResource("test.xml");
XMLReader reader = XMLReaderFactory.createXMLReader("org.apache.xerces.parsers.SAXParser");
reader.setEntityResolver(new HibernateMappingDTDEntityResolver());
reader.parse(new InputSource(xmlFileResource.getInputStream()));
```