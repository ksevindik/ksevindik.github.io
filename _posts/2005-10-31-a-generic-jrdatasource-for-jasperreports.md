# A Generic JRDataSource for JasperReports

It is possible to pass data to JasperReports templates via a custom data source, which implements the `JRDataSource` 
interface. The reporting engine iterates over the report data collection with the boolean `next()` method and evaluates 
field expressions by requesting values for them from the data source instance using the `Object getFieldValue(JRField)` 
method. One most probably implements custom data sources by returning some property value of the current data record 
corresponding to a field name passed from the template via the reporting engine.

We have developed a concrete `JRDataSource` class, which takes a list as a record data collection in its constructor and 
then returns field values, extracting them via reflection from the current record data in the collection if there is a 
one-to-one correspondence between that record's properties and field expressions in the report template. There is no 
restriction on the depth of the object structure while extracting field values. For example, we may have an object named 
A as the current record data, but may ask a field value which corresponds to some property of an object named B, which 
is also a property of the previous object named A. The sole requirement for this idiom to work is implementing getter 
methods for those properties mentioned above.

Below is a simple usage scenario. Let's say we have two classes, `Foo` and `Bar`, as follows;

```java
public class Foo {
    private float f;
    private Bar bar;
    public Bar getBar() {
        return bar;
    }

    public float getF() {
        return f;
    }
    ...
}

public class Bar {
    private int i;
    private String str;
    public int getI() {
        return i;
    }

    public String getStr() {
        return str;
    }
    ...
}
```

Later, we can define field expressions such as, assuming an instance of class `Foo` is the top-level report data record, 
`bar.str`, `bar.i`, `f`, and access them with `$F{bar.str}`, `$F{bar.i}`, `${f}` expressions respectively inside report 
templates.

Here is the source code of this custom data source idiom;
```java
public class ListJRDataSource implements JRDataSource {
    private Iterator iterator;
    private Object currentObject;
    public ListJRDataSource(List objectList) {
        iterator = objectList.iterator();
    }

    public boolean next() throws JRException {
        if(iterator.hasNext()) {
            currentObject = iterator.next();
            return true;
        } else {
            return false;
        }
    }

    public Object getFieldValue(JRField jrField) throws JRException {
        String fieldName = jrField.getName();
        return FieldValueGetter.getValue(currentObject,fieldName);
    }
}

public class FieldValueGetter {
    public static Object getValue(Object target, String property) {
        int index = property.indexOf(".");
        if(index != -1) {
            target = getFieldValue(target,property.substring(0,index));
            return target != null?getValue(target,property.substring(index + 1)):null;
        } else {
            return target != null?getFieldValue(target,property):null;
        }
    }

    private static Object getFieldValue(Object target, String property) {
        try {
            property = convertToGetter(property);
            Method method = target.getClass().getMethod(property,null);
            return method.invoke(target,null);
        } catch (Exception e) {
            throw new FieldValueAccessException(e.getMessage(),e);
        }
    }

    private static String convertToGetter(String property) {
        StringBuffer buf = new StringBuffer();
        buf.append("get");
        buf.append(property.substring(0,1).toUpperCase(Locale.US));
        buf.append(property.substring(1));
        return buf.toString();
    }
}
```
