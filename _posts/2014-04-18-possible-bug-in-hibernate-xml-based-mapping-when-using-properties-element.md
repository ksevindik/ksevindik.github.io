# Possible bug in Hibernate XML based mapping when using properties element

Assume you have a Person with firstName and lastName properties, and a subclass of it called as Vet. You will have 
hbm.xml mapping files with the following content.

Person.hbml.xml

```xml
<hibernate-mapping>
    <class name="com.javaegitimleri.petclinic.model.Person"
           table="persons"
           abstract="true">
        <cache usage="read-write" />
        <id name="id" column="ID" access="field">
            <generator />
        </id>
        <version name="version" column="VERSION" type="integer"
                 access="field" />
        <properties name="firstAndLastName" unique="true">
            <property name="firstName" column="FIRST_NAME"
                      type="string" />
            <property name="lastName" column="LAST_NAME"
                      type="string" />
        </properties>
    </class>
</hibernate-mapping>
```

Vet.hbm.xml

```xml
<hibernate-mapping>
 <joined-subclass name="com.javaegitimleri.petclinic.model.Vet"
 extends="com.javaegitimleri.petclinic.model.Person"
 table="vets">
 <key column="ID"/>
 </joined-subclass>
 </hibernate-mapping>
```

If you run a HQL like “from Vet v where v.lastName = ‘Doe'”, you will have an error indicating that LAST_NAME column not 
found in VETS table. Here is the SQL generated from this query in H2 database.

```sql
select
vet0_.ID as ID72_,
vet0_1_.VERSION as VERSION72_,
vet0_1_.FIRST_NAME as FIRST3_72_,
vet0_1_.LAST_NAME as LAST4_72_
from
vets vet0_
inner join
persons vet0_1_
on vet0_.ID=vet0_1_.ID
where
vet0_.LAST_NAME='y'
```

The problem is caused by element which is put to define a unique constraint on firstName and lastName properties together. 
Unfortunately, this grouping element causing hibernate not to realize that lastName attribute is defined in Person when 
it is accessed from its subclass within the query. When element is removed, HQL works as expected. This is probably a bug 
in xml based mapping.