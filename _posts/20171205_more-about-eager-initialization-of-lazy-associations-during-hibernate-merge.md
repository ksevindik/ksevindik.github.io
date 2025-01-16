# More about Eager Initialization of Lazy Associations During Hibernate Merge

After reading my blog post about eager initialization of lazy 1:1 or M:1 associations because of the cascade merge attribute, 
someone asked about if it applies for 1:M and M:N associations as well? The answer is, yes it applies.

Let’s create another small entity in order to illustrate that case as well.

```java
@Entity
@Table(name="T_BAZ")
public class Baz {
    @Id
    @GeneratedValue
    private Long id;
    
    public Long getId() {
        return id;
    }
}
```

Then, we add a 1:M association within Foo entity as follows.

```java
@Entity
@Table(name="T_FOO")
public class Foo {
//...
    @OneToMany(cascade=CascadeType.MERGE)
    @JoinColumn(name="foo_id")
    private Collection<Baz> bazList = new ArrayList<>();

    public Collection<Baz> getBazList() {
        return bazList;
    }

    public void setBazList(Collection<Baz> bazList) {
        this.bazList = bazList;
    }
//...
}
```

As you all know, 1:M and M:N associations are lazy by default, so there is no need for a fetch attribute. Only 
cascade=CascadeType.MERGE is added.

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

When we try to access Foo entity via Session.get(), above select query is issued to fetch Foo entity only. A separate 
select SQL to initialize lazy bazList collections is issued only when we attempt to access its contents.

```java
System.out.println(foo.getBazList().size());
```

```sql
select
bazlist0_.foo_id as foo_id2_21_0_,
bazlist0_.id as id1_21_0_,
bazlist0_.id as id1_21_1_
from
T_BAZ bazlist0_
where
bazlist0_.foo_id=?
```

Same story up to this point. However, when we try to merge detached Foo entity, we will see following SQL query is issued, 
fetching 1:M bazList entries eagerly!

```java
session.merge(foo2);
```

```sql
/* load org.speedyframework.persistence.hibernate.test.Foo */ select
foo0_.id as id1_22_2_,
foo0_.bar_id as bar_id2_22_2_,
bar1_.id as id1_20_0_,
bazlist2_.foo_id as foo_id2_21_4_,
bazlist2_.id as id1_21_4_,
bazlist2_.id as id1_21_1_
from
T_FOO foo0_
inner join
T_BAR bar1_
on foo0_.bar_id=bar1_.id
left outer join
T_BAZ bazlist2_
on foo0_.id=bazlist2_.foo_id
where
foo0_.id=?
```

![](images/hibernate_shoot_yourself.jpg)

After playing with Hibernate for about more than a decade, I strongly feel that it is much better and safer to consider 
ORM in general, Hibernate in particular only as an advanced SQL mapper, nothing more. Quite a few features of ORM tools 
which look simple, safe and effective in small scale, gets more complicated, may cause side effects, and unexpected 
problems in a big landscape. Of course, I am not saying Hibernate/ORM is bad, and don’t use it, but what I am saying that 
don’t expect too much from it, and beware that you might easily shoot yourself on your foot unless you are very careful 
while employing ORM in your projects.

