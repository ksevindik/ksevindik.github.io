# Lookup Tables with Hibernate and JSF
Every project comprises several tables containing data mainly in the form of a code-name pair. These tables define states, 
types, or other similar values as codes, which will be referenced from other tables in the database. Furthermore, their 
name values are utilized in the GUI to provide users with an understanding of what those code values truly signify in real 
business contexts, essentially serving as descriptive values. Such tables are generally referred to as 'lookup tables,' 
'reference tables,' or 'decode tables.'

The number of code-name pairs may increase or decrease, and their content may change from time to time. Hence, developed 
systems should take this into account and behave accordingly. Systems should never directly define such code and name 
values in the source code but should instead fetch them from the database.

We have many such lookup tables in our current project as well. As a result, we need to develop a generic way to fetch 
the values of these tables and utilize them in the model and GUI layers. Some domain classes have dependencies on these 
lookup values, and we need to automatically create the entire database schema from Hibernate mapping files. Therefore, we 
decided to model these lookup values as first-class objects. Otherwise, they would be primitive numeric types in the 
domain model, and we would have to manually maintain relationships among domain tables and lookup tables.

```java
/**
 * @hibernate.class
 */
public class Personel {
    ...
    private Country country;
    ...
    /**
     *@hibernate.many-to-one not-null=”true”
     */
    public Country getCountry() {
        return country;
    }
}

/**
 * @hibernate.class
 */
public class Country {
    private Long id;
    private String name;
    
    /**
     * @hibernate.id
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @hibernate.property
     */
    public String getName() {
        return name;
    }
}
```
The country is mapped here as a lookup table. We need a generic lookup mechanism to provide available countries to be 
used in the system. Our LookupDAO class provides this functionality.

```java
public class LookupDAO extends HibernateDaoSupport {
    public List getLookupObjectList(Class type) {
        return getHibernateTemplate().loadAll(type);
    }
    
    public Object getLookupObject(Class type, Long id) {
        return getHibernateTemplate().load(type,id);
    }
}
```

We have also declared an ILookupObject interface to utilize in JSF value binding and Converter, and each lookup class 
implements that interface as well.

```java
public interface ILookupObject {
    public Object getThis();
    public Long getId();
    public String getName();
}
```

The business and presentation layers utilize the above methods to retrieve the country list or any specific country if 
they know its ID. We employ JavaServer Faces to implement the presentation layer and need another generic way to bind 
those lookup values to JSF components, such as comboboxes, lists, and checkboxes. Below, you can see how we accomplish 
this with the selectOneMenu JSF component.

```xml
<h:selectOneMenu id="cmbCountries" value="#{personelPageCode.personel.country }" styleClass="selectOneMenu" converter="lookupObjectConverter">
    <f:selectItems value="#{selectitems.personelPageCode.countries.name.this.toArray}" />
</h:selectOneMenu>
```

The combobox lists all available countries by evaluating the value binding #{selectitems.personelPageCode.countries.name.this.toArray} EL. 
personelPageCode.getCountries() returns the available country object using LookupDAO.getLookupObjectList().

A careful eye should immediately catch the oddness in this EL. The combobox component requires a distinct identifier 
value, which usually is an integer value. Instead, we gave the entire lookup object instance as the identifier value 
using the 'this' keyword. JSF uses the 'lookupObjectConverter' we defined above to produce that identifier value. While 
rendering selectable items, each country lookup object fetched by calling getThis(), in which lookup objects return 
themselves, is passed into Converter.getAsString(…) method. This method returns getClass().getName() + ":" + getId() as 
the identifier value.

```java
public String getAsString(FacesContext facesContext, UIComponent component, Object lookupObject) {
    try {

        String type = lookupObject.getClass().getName();

        return type + ":" + ((ILookupObject) lookupObject).getId();

    } catch (Exception e) {
        throw new ConverterException("Error during LookupObject conversion", e);
    }
}

public Object getAsObject(FacesContext facesContext, UIComponent component, String value) {

    try {
        String[] parts = value.split(":");
        String type = parts[0];
        Long id = Long.valueOf(parts[1]);
        Class type = Class.forName(type);
        Object lookupObject = getLookupDAO().getLookupObject(type, id);
        return lookupObject;
    } catch (Exception e) {
            throw new ConverterException("Error during LookupObject conversion", e);
    }
}
```

When a country object is selected, JSF sets the personel.country model property, retrieving the current lookup object 
using Converter.getAsObject(…) method.

As a result, we have come up with a truly useful 'JSF-Hibernate' Java idiom to map and bind lookup tables in the model 
and GUI.