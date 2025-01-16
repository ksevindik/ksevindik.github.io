# Mockito and Extension Functions in Kotlin

Being able to define extension functions to classes that belong to third-party libraries looks very nice at the first 
point. However, they might become a road blocker during your unit testing, if you are working with Mockito as the mocking 
library. Let’s talk about the problem using an example, let’s write an extension function to Spring’s ResourceLoader class, 
which will be used to get text content via its getResource method within it.

```kotlin
fun ResourceLoader.getTextContent(location:String) : String {
    val resource = this.getResource(location)
    return IOUtils.toString(FileReader(resource.file))
}
```

Then let’s try to mock and train it as follows;

```kotlin
    @Test
    fun `it should result textual content`() {
        val mock = Mockito.mock(ResourceLoader::class.java)
        Mockito.doReturn("hello world!").`when`(mock).getTextContent("myfile")

        val result = mock.getTextContent("myfile")
        MatcherAssert.assertThat(result,Matchers.equalTo("hello world!"))
    }
```

When we run the above code block, we will get an exception, which indicates that the actual body of the getTextContent() 
method is being invoked instead of the trained one.

```stacktrace
String cannot be returned by getResource()
getResource() should return Resource
***
If you're unsure why you're getting above error read on.
Due to the nature of the syntax above problem might occur because:
1. This exception *might* occur in wrongly written multi-threaded tests.
   Please refer to Mockito FAQ on limitations of concurrency testing.
2. A spy is stubbed using when(spy.foo()).then() syntax. It is safer to stub spies - 
   - with doReturn|Throw() family of methods. More in javadocs for Mockito.spy() method.

org.mockito.exceptions.misusing.WrongTypeOfReturnValue: 
String cannot be returned by getResource()
getResource() should return Resource
***
If you're unsure why you're getting above error read on.
Due to the nature of the syntax above problem might occur because:
1. This exception *might* occur in wrongly written multi-threaded tests.
   Please refer to Mockito FAQ on limitations of concurrency testing.
2. A spy is stubbed using when(spy.foo()).then() syntax. It is safer to stub spies - 
   - with doReturn|Throw() family of methods. More in javadocs for Mockito.spy() method.

	at app//com.example.test.Extensions.getTextContent(Extensions.kt:21)
        ...
```

The reason for that problem is the way how extension functions are implemented in Kotlin. They are simply defined as 
static methods. Therefore, when you invoke the extension function through the mock object, the static method is being 
invoked instead of the trained one in your mock instance. You can find more information about it here.

So what is the solution? Unfortunately, there seems no solution for this in Mockito, yet. You might, however, follow the 
approach of creating a seam point by encapsulating invocation of that extension function within another method in your 
object which is currently being tested, spy it, and train that method to return what you expect. That way you are able to 
defer the testing of the invocation of the extension function to a later point, such as integration tests, within which 
you don’t need to mock its owning object at all.

If you give up Mockito, and choose Mockk, which is another mocking library, particularly designed and developed for Kotlin, 
then you have the option to mock extension functions.
