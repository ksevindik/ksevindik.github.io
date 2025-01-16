# Mocking ResourceBundle
If you want to unit test a method that depends on **java.util.ResourceBundle** and you want to isolate bundle access code by 
mocking ResourceBundle, using, for example, the JMock Dynamic Mocking Library, you will face a restriction. Commonly used 
methods such as **getString(key)** are defined as final in the ResourceBundle class, and there is no way to extend and override 
final method declarations.

Fortunately, there is an abstract subclass called **ListResourceBundle** which can be used during unit test setups to mock 
ResourceBundle usage. The following excerpt is from a unit test that involves a JSF backing bean fetching application 
messages from a ResourceBundle during runtime:

```java
public class ApprovalPageCode {
    private ResourceBundle resourceBundle;
    public ResourceBundle getResourceBundle() {
        if(resourceBundle == null) {
            resourceBundle = ResourceBundle.getBundle("msgResources");
        }
        return resourceBundle;
    }
    public void setResourceBundle(ResourceBundle resourceBundle) {
        this.resourceBundle = resourceBundle;
    }
    public String doSuccessOperation() {
        String outcome = getResourceBundle().getString("msgSuccess");
        return outcome;
    }
}

public class TestApprovalPageCode extends TestCase {
    class MsgResourceBundle extends ListResourceBundle {
        private Object[][] contents = new Object[][]{
            {"msgSuccess","success message"},
            {"msgError","error message"}
        };
        protected Object[][] getContents() {
            return contents;
        }
   };
   public void testSuccess() {
       ApprovalPageCode pageCode = new ApprovalPageCode();
       pageCode.setResourceBundle(new MsgResourceBundle());
       String outcome = pageCode.doSuccessOperation();
       assertEquals(outcome,"success message");
   }
}
```

As seen above, **ApprovalPageCode** requires a ResourceBundle and creates one using a property file if no resource bundle is 
provided with it using its setter method. During unit testing, we created an inner class named **MsgResourceBundle**, which 
extends ListResourceBundle to provide the required messages, and set an instance of it into the ApprovalPageCode instance 
before running the test method. As a result, our test is isolated from accessing the file system to create a resource 
bundle during unit tests.