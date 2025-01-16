# When It is Useful to Make Use of JPA @MapKey?

![](images/jpa_hibernate_mapkey.png)

As you probably know, JPA provides a way to map collection associations using `java.util.Map`. However, usage scenarios 
for such mappings are very limited; but when it comes, they become highly invaluable to easily extract necessary 
information from your domain model. They are especially useful in order to categorize entities in your associated 
collection based on some unique key property. I prepared two mapping examples in order to show you how `java.util.Map` 
can become useful in your projects.

Let’s assume you have a `Document` entity, and it has a `description` property. However, you have I18n requirements, and 
you need to store/display different `description` values based on a given `Locale` information. Let’s also assume that 
you need to keep track of changes made on document content each time its content is uploaded from the client, for example, 
store path info for each upload separately. You can store those uploads in another entity and distinguish among them by
using an `uploadVersion` property. Following code snippet shows how such a domain model can be created and mapped using 
JPA.

```java
@Entity
public class Document {
	
	@Id
	@GeneratedValue(strategy=GenerationType.AUTO)
	private Long id;
	
	@OneToMany(cascade=CascadeType.ALL)
	@MapKey(name="locale")
	@JoinColumn(name="DOC_ID")
	private Map descriptionsByLocale = new HashMap<>();
	
	@OneToMany(cascade=CascadeType.ALL)
	@MapKey(name="uploadVersion")
	@JoinColumn(name="DOC_ID")
	private Map uploadsByVersion = new HashMap<>();
	
//...
}
```

Here above, we’ve placed `@MapKey`, in addition to `@OneToMany` annotation in order to map `descriptionsByLocale` and 
`uploadsByVersion` `java.util.Map` properties. Unless you provide `@MapKey` with a `name` attribute, which needs to be a 
persistent property defined in the target entity, JPA assumes it will use the target entity’s primary key as an identifier 
by default. We can give any other persistent property which can be used to uniquely identify entities within the mapped 
collection.

```java
@Entity
public class DocDescription {
	@Id
	@GeneratedValue(strategy=GenerationType.AUTO)
	private Long id;
	
	@Column(name="DOC_LOCALE",unique=true,nullable=false)
	private Locale locale;
	
	private String content;
//...
}

@Entity
public class DocUpload {
	@Id
	@GeneratedValue(strategy=GenerationType.AUTO)
	private Long id;
	
	@Column(unique=true,nullable=false)
	private Integer uploadVersion;
	
	private String uploadPath;
//...
}
```

As `locale` and `uploadVersion` properties are unique in our `DocDescription` and `DocUpload` entities, we can safely 
make use of them as map keys in our mapping. Finally, we can add getter methods into our `Document` entity in order to 
access specific entities based on their keys.

```java
    public Collection getDescriptions() {
		return descriptionsByLocale.values();
	}
	
	public DocDescription getDescription(Locale locale) {
		return descriptionsByLocale.get(locale);
	}
	
	public Collection getUploads() {
		return uploadsByVersion.values();
	}
	
	public DocUpload getUpload(Integer version) {
		return uploadsByVersion.get(version);
	}
```

I hope those two usage scenarios make it clear to you when it is useful to make use of `@MapKey` annotation and 
`java.util.Map` typed properties in your domain mappings. Do you have any other usage scenarios for maps? I’d love to hear.
