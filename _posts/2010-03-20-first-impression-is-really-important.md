# First Impression Is Really Important

I have attended a 3-day workshop for Oracle Coherence Product. Although I am a veteran Eclipse user, we used JDeveloper 
11g Technology Preview 3 during our lab sessions. During those lab sessions, I noticed an issue related to JDeveloper. 
JDeveloper provides some IDE mechanisms to generate `equals` and `hashCode` methods for your classes. However, it fails 
to generate `hashCode` methods correctly when your classes contain primitive fields that need to be included in `hashCode` 
generation.

```java
public class Foo {
	private int id;
	public int hashCode() {
		final int PRIME = 37;
		int result = 1;
		return result;
	}
}
```

Above is the code block I just generated using JDeveloper. Although I chose `id` to include when generating `hashCode`, 
it doesn’t have it. As a result, you have the same `hashCode` value for all your `Foo` objects. This is not good if you 
are dealing with data structures like `Hashtable` in your application. To generate it correctly, you simply need to convert 
your primitive type to its Java wrapper equivalent. After this conversion, it looks more appropriate than above:

```java
public int hashCode() {
	final int PRIME = 37;
	int result = 1;
	result = PRIME * result + id == null) ? 0 : id.hashCode(?;
	return result;
}
```

In summary, I think it is really important for a new product to handle some fundamental tasks appropriately to gain 
acceptance by its users.
