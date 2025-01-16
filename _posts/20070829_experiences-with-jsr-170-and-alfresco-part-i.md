# Experiences with JSR-170 and Alfresco, Part I
Nowadays, I have found a chance to read about Java Content Repository API specification, also known as `JSR-170`, and play 
with `Alfresco`, which is a nice implementation of it.

More specifically, I have focused on developing a wiki model using content repository constructs available in `Alfresco`. 
It is obvious that contents which are hierarchical in nature, e.g., wiki systems, have a very nice fit within `JSR-170` 
concepts. More will come about that wiki model later; for now, I want to mention some initial observations related to 
`Alfresco Content Management System`.

First of all, I admit that they have nicely introduced aspect-oriented programming concepts into their architecture to 
dynamically add and remove behaviors to the content types. You have basically two different ways to declare new types. 
The first one is the static way. Your content type can inherit from one of the parent content types available in the 
model.

```xml
<type name="wiki:entry">
  <title>Wiki Entry Base</title>
  <parent>cm:content</parent>
  <properties>
        <property name="wiki:category">
              <type>d:text</type>
              <multiple>true</multiple>
        </property>
  </properties>
</type>
```

For example, `wiki:entry` type inherits from parent type `cm:content`. It is similar to inheriting from a Java
class. By that way, you inherit all the properties and behaviors of your parent type. But what about if you want to
introduce additional behaviors in your custom type even during runtime? They have employed AOP to overcome this problem.
For example, we want to add versioning behavior in our `wiki:entry` type in addition to the `cm:content`. To do that, we 
add an aspect into our type definition.

```xml
<type name="wiki:entry">
  <title>Wiki Entry Base</title>
  <parent>cm:content</parent>
  <properties>
        <property name="wiki:category">
              <type>d:text</type>
              <multiple>true</multiple>
        </property>
  </properties>

  <mandatory-aspects>
        <aspect>cm:versionable</aspect>
  </mandatory-aspects>
</type>
```

`cm:versionable` is a predefined aspect in the content model of `Alfresco`. It 
has properties like version label, version number, etc. Whenever a new node with type `wiki:entry` is created, that aspect 
is applied, and those properties and any other behavior applied to that `wiki:entry` instance. You can even programmatically 
add and remove such behavior into your nodes.

In summary, I am happy to see AOP concepts in action other than basic logging and tracing AOP samples and classic Spring 
interceptor practices.
