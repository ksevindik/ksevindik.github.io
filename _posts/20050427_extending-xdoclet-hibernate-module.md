# Extending XDoclet Hibernate Module
As you may be aware, Hibernate's bag collection type stores its elements unordered, unindexed, and may contain multiple 
copies of the same element instance. Since the Java Collection Framework does not inherently provide a concept of a bag, 
we typically use the available List type to implement bag semantics in Java, even though List maintains its elements ordered.

From a performance standpoint, using a bag as a collection value mapping in Hibernate is generally suboptimal. This is 
because there is no index or primary key column, and duplicate elements may exist in the database. Hibernate lacks the 
means to distinguish among these duplicate elements for updates. To resolve this issue, Hibernate typically first deletes 
all collection elements in one operation and then inserts all values again.

Hibernate provides a special type of bag element called "idbag," which allows us to define a surrogate primary key or 
synthetic identifier for each bag element. Hibernate's idbag mappings are much more efficient than their bag counterparts 
due to the surrogate primary key. With this key, Hibernate can locate and update individual bag elements that have been 
modified.

Unfortunately, there is no mechanism in the XDoclet Hibernate module to define idbag mappings. Therefore, we have modified 
and added this feature to define them using XDoclet tags. The Hibernate idbag element requires a collection-id sub-element 
to create a surrogate key. Therefore, we first added the following lines into the hibernate-collections.xdt file.
```xml
<XDtMethod:ifHasMethodTag tagName="hibernate.collection-id">
    <collection-id column="<XDtMethod:methodTagValue tagName="hibernate.collection-id" paramName="column" />"

type="<XDtMethod:methodTagValue tagName="hibernate.collection-id" paramName="type" />"
                                               <XDtMethod:ifHasMethodTag tagName="hibernate.collection-id" paramName="length">
                                                            length="<XDtMethod:methodTagValue tagName="hibernate.collection-id" paramName="length" />"
                                               </XDtMethod:ifHasMethodTag>                     
    <XDtMethod:ifHasMethodTag tagName="hibernate.collection-id" paramName="generator-class">
        <generator class="<XDtMethod:methodTagValue tagName="hibernate.collection-id" paramName="generator-class" />"/>
</XDtMethod:ifHasMethodTag>
</collection-id>
</XDtMethod:ifHasMethodTag>
```
Our second modification is applied to the hibernate-properties.xdt file:
```xml
<XDtMethod:ifHasMethodTag tagName="hibernate.idbag">
    <idbag
        <XDtHibernate:roleAttribute/>="<XDtMethod:propertyName/>"
        <XDtMethod:ifHasMethodTag tagName="hibernate.idbag" paramName="table">
        table="<XDtMethod:methodTagValue tagName="hibernate.idbag" paramName="table" />"
</XDtMethod:ifHasMethodTag>

<XDtMethod:ifHasMethodTag tagName="hibernate.idbag" paramName="schema">
    schema="<XDtMethod:methodTagValue tagName="hibernate.idbag" paramName="schema" />"
</XDtMethod:ifHasMethodTag>

    lazy="<XDtMethod:methodTagValue tagName="hibernate.idbag" paramName="lazy" values="true,false" default="false"/>"
    cascade="<XDtMethod:methodTagValue tagName="hibernate.idbag" paramName="cascade" values="none,all,save-update,delete,all-delete-orphan,delete-orphan" default="none"/>"
<XDtMethod:ifHasMethodTag tagName="hibernate.idbag" paramName="order-by">
order-by="<XDtMethod:methodTagValue tagName="hibernate.idbag" paramName="order-by" />"
</XDtMethod:ifHasMethodTag>
<XDtMethod:ifHasMethodTag tagName="hibernate.idbag" paramName="where">
    where="<XDtMethod:methodTagValue tagName="hibernate.idbag" paramName="where" />"
</XDtMethod:ifHasMethodTag>
>
<XDtMerge:merge     
    file="xdoclet/modules/hibernate/resources/hibernate-collections.xdt">
/XDtMerge:merge>
    </idbag>
</XDtMethod:ifHasMethodTag>
```

And finally, we need to add the following lines into the xtags.xml file to enable the JBoss IDE XDoclet Code Assist feature 
to recognize these additions:
```xml
<tag>
    <level>method</level>
    <name>hibernate.idbag</name>
    <usage-description>Defines an idbag</usage-description>
    <unique>true</unique>
    <condition-description>Hibernate</condition-description>
    <condition type="method"/>
    <parameter type="text">
        <name>table</name>
        <usage-description>The name of the collection table (not used for one-to-many associations)</usage-description>
        <mandatory>false</mandatory>
    </parameter>
    <parameter type="text">
        <name>schema</name>
        <usage-description>The name of a table schema to override the schema declared</usage-description>
        <mandatory>false</mandatory>
    </parameter>
    <parameter type="bool">
        <name>lazy</name>
        <usage-description>Enable lazy initialization</usage-description>
        <mandatory>false</mandatory>
        <default>false</default>
       </parameter>
    <parameter type="text">   
        <name>cascade</name>
        <usage-description>Specifies which operations should be cascaded from the parent object to the associated object</usage-description>
        <mandatory>false</mandatory>
        <default>none</default>
        <option-sets>
            <option-set>
                <options>
                 <option>all</option>
                 <option>none</option>
                 <option>save-update</option>
                 <option>delete</option>
                 <option>all-delete-orphan</option>
                 <option>delete-orphan</option>
                </options>
             </option-set>
         </option-sets>
     </parameter>
    <parameter type="text">
       <name>order-by</name>
       <usage-description>Specify table columns that define the iteration order</usage-description>
       <mandatory>false</mandatory>
     </parameter>
     <parameter type="text">
        <name>where</name>
        <usage-description>An SQL WHERE condition</usage-description>
        <mandatory>false</mandatory>
     </parameter>
</tag>
```
Here's a sample Java comment that demonstrates how the idbag collection mapping can be done with the newly defined XDoclet 
tags. This example attempts to establish a one-to-many relationship between Set and Game. As you can see, there is no 
difference from bag collection mapping, except for the addition of the collection-id tag.
```java
/**
*
* @hibernate.idbag table = "GAME" order-by = "GAME_ID asc"
* @hibernate.collection-id column = "GAME_ID" type="integer"
* length="10" generator class="native"
* @hibernate.collection-key column = "FK_SET_ID"
* @hibernate.collection-composite-element class = "model.Game"
*/
```

Our second modification is for creating many-to-many relationships, where one side of the relationship's primary key 
consists of more than one column. Currently, the XDoclet Hibernate module does not support this, so we modified the lines 
for the hibernate.collection-many-to-many tag in the hibernate-collections.xdt file as follows:

This modification helps us to obtain the following excerpt:
```xml
<many-to-many class="model.Module" outer-join="auto">
    <column name="MODULE_CODE" />
    <column name="MODULE_NO" />
</many-to-many>
```
The Java comment to generate the above output is as follows:
```java
/**
  * @hibernate.list table = "DEVELOPER_MODULE" cascade = "save-update"
  * @hibernate.collection-key column = "FK_DEVELOPER_ID"
  * @hibernate.collection-index column = "ORDER_NO"
  * @hibernate.collection-many-to-many class = "model.Module"

  * @hibernate.column name = "MODULE_CODE"
  * @hibernate.column name = "MODULE_NO"
*/
```




