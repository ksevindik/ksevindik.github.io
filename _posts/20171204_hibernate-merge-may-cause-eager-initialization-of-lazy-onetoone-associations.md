# Hibernate Merge may Cause EAGER Initialization of LAZY OneToOne Associations

Let’s have following two simple entities, having 1:1 lazy association between each other.

```java
@Entity
@Table(name="T_FOO")
public class Foo {
 @Id
 @GeneratedValue
 private Long id;

@OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.MERGE)
 @JoinColumn(name = "bar_id")
 private Bar bar;

public Long getId() {
 return id;
 }

public Bar getBar() {
 return bar;
 }

public void setBar(Bar bar) {
 this.bar = bar;
 }
}

@Entity
@Table(name="T_BAR")
public class Bar {
 @Id
 @GeneratedValue
 private Long id;
 
 public Long getId() {
 return id;
 }
}
```

When you fetch a Foo entity from database, either via Session load, or via HQL, or Criteria API doesn’t matter, it fetches 
only Foo entity, and places a proxy instance in place of Bar instance. Following excerpt illustrates this. Because of the 
LAZY fetch type, Bar isn’t fetched when Foo instance is loaded.

```java
Foo foo = session.get(Foo.class, 1L);
```

```sql
Hibernate: 
 select
 foo0_.id as id1_21_0_,
 foo0_.bar_id as bar_id2_21_0_ 
 from
 T_FOO foo0_ 
 where
 foo0_.id=?
```

So far, everything is as expected. For example, when we try to access lazy Bar association, Hibernate issues a select SQL 
to initialize Bar proxy.

```java
System.out.println(foo.getBar().getId());
```

```sql
Hibernate: 
 select
 bar0_.id as id1_20_0_ 
 from
 T_BAR bar0_ 
 where
 bar0_.id=?
```

However, things get looking strange when we try to merge a detached Foo instance, as follows.

```java
session.merge(foo);
```

```sql
/* load org.speedyframework.persistence.hibernate.test.Foo */ select
 foo0_.id as id1_21_1_,
 foo0_.bar_id as bar_id2_21_1_,
 bar1_.id as id1_20_0_ 
 from
 T_FOO foo0_ 
 inner join
 T_BAR bar1_ 
 on foo0_.bar_id=bar1_.id 
 where
 foo0_.id=?
```

As we notice in the generated select SQL, Bar instance is being eagerly fetched while Foo instance is being loaded during 
merge operation. This is because of cascade=CascadeType.MERGE attribute in the 1:1 association. As the merge operation is 
going to be cascaded towards the target Bar instance, Hibernate decides that it will be more performant to join T_FOO and 
T_BAR tables and loads Bar instance as well.

At this point, we might ask what is the problem with such an eager initialization apart from a slight behavioral 
inconsistency between load triggered through merge and direct invocation of load via Session API. However, think about 
an entity having tons of 1:1 associations of such type, and you are using MySQL as the database. You might hit max number 
of tables in a join limitation in your query if number of 1:1 associations exceeds 61 in your mappings! Or you might be 
using MS SQL Server with tons of such 1:1 associations again, and your query lots of JOINS might hit 8 KB max row page 
size limitation!

As a result, such an inconsistency between two load behaviors in different parts of Hibernate Session might cause you some 
headaches, and force you to remove those cascade MERGE definitions in your mappings in the end.

