# Hibernate EntityCopyObserver: What Is It Used For?

JPA merge operation is used to reconnect and synchronize detached entities with active PersistenceContext so that changes 
performed on them could be reflected onto the database. Due to its complex nature, there might be times when multiple 
representations of an entity appears in the merge  process. Hibernate throws IllegalStateException in that case, because 
allowing each representation to be merged might have resulted in database inconsistency. The point at which this error 
raised is og.hibernate.event.spi.EntityCopyObserver. When duplication detected, its implementation EntityCopyNotAllowedObserver 
invoked, which throws IllegalStateException to terminate the merge operation.

There might be times at which this problem appears in your project mostly due to the inappropriate use of cascade definitions 
on many to one associations in your domain model, and because of some complex steps executed within your scenarios which 
loads and merges those entities several times during the course of the business scenario. You may want Hibernate to allow 
merging of those multiple representations. You can switch to this behavior via hibernate configuration property called  
hibernate.event.merge.entity_copy_observer. It accepts values disallow (default), allow, and log. You can also create 
your own implementation of EntityCopyObserver and introduce it via this property. In that case, it is enough to write 
FQN of your custom implementation class.

However, you should be aware that because of the undefined order of cascades among associations in an entity, if there 
are different changes in those multiple representations, the resulting change appear in your database might be something 
different then what you expect. In such cases, it is also possible to come up with an OptimisticLockException if your 
entities have version control enabled.

The following sample domain model and scenario demonstrates this problem.

```java
@Entity
@Table(name="T_A")
public class A {
    @Id
    @GeneratedValue
    private Long id;
    
    private String name;
    
    @ManyToOne(cascade=CascadeType.MERGE)
    private B x;
    
    @ManyToOne(cascade=CascadeType.MERGE)
    private B y;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public B getX() {
        return x;
    }

    public void setX(B x) {
        this.x = x;
    }

    public B getY() {
        return y;
    }

    public void setY(B y) {
        this.y = y;
    }
}

@Entity
@Table(name="T_B")
public class B {
    @Id
    @GeneratedValue
    private Long id;
    
    private String name;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}

Session session = sessionFactory.openSession();
session.beginTransaction();
        
A a = new A();
a.setName("a");
        
B b = new B();
b.setName("b");
        
session.persist(b);
a.setX(b);
session.persist(a);
        
session.flush();
        
session.clear();
        
a = session.get(A.class, a.getId());
        
a.setY(b);
        
a.getX().setName("bb");
        
b.setName("bbb");
        
session.merge(a);
        
session.getTransaction().commit();
```

When you switch hibernate.event.merge.entity_copy_observer property to allow or log, you will see that error disappears. 
However, column value of B.name property in database might be either “bb”, or “bbb”. You can introduce version control 
to entity B prevent such inconsistent modifications at least while still allowing multiple representations to appear in 
associations.