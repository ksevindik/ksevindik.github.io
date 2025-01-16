# JdbcTemplate ve IN clause

Farz edelim ki elinizde `select r.id, r.rolename from role_table r where r.rolename in (?)` şeklinde bir sorgu olsun. 
Başka bir deyişle bir veya daha fazla sayıda `rolename` değeri içeren bir liste ile `role_table`’daki kayıtların bir 
bölümünü sorgulamak istiyorsunuz. Eğer aşağıdaki gibi bir kod yazarsanız;

```java
List listOfRoleNames = new ArrayList();
listOfRoleNames.add("role_user");
listOfRoleNames.add("role_editor");
jdbcTemplate.query("select r.id, r.rolename from role_table r where r.rolename in (?)", 
    new Object[]{listOfRoleNames}, new RowMapper() {    
        public Object mapRow(ResultSet rs, int rowNum) throws SQLException {        
        return new Role(rs.getLong(1),rs.getString(2));    
    }
});
``` 

yazdığınız kod beklediğiniz sonucu vermeyecektir. Çünkü buradaki sorgunun `where` condition’ında `listOfRoleNames`’de kaç 
tane eleman bulunuyorsa o kadar sayıda `?` koymanız gerekmektedir. `JdbcTemplate` sorgudaki `?` işareti kadar verilen 
`Object` array üzerinde iterate edecek ve her bir `?` işareti için array’den bir eleman alacaktır. Eğer sorgularınızın 
`where` condition’ında dinamik olarak değişen sayıda input değişken kullanmak istiyorsanız bunun için `NamedParameterJdbcTemplate` 
kullanmanız ve sorgunuzu da `select r.id, r.rolename from role_table r where r.rolename in (:roleNames)` şeklinde yazmanız gerekir.

```java
List listOfRoleNames = new ArrayList();
listOfRoleNames.add("role_user");
listOfRoleNames.add("role_editor");
namedParameterJdbcTemplate.query("select r.id, r.rolename from role_table r where r.rolename in (:roleNames)", new Object[]{listOfRoleNames}, 
new RowMapper() {    
    public Object mapRow(ResultSet rs, int rowNum) throws SQLException {        
        return new Role(rs.getLong(1),rs.getString(2));    
    }
});
``` 

`NamedParameterJdbcTemplate` asıl işi yine kendi içindeki sıradan `JdbcTemplate` nesnesine delege etmektedir. Bu arada 
`roleNames` listesindeki elemanların sayısının, veritabanları değişken sayıdaki input parametreler için “hard limit” 
koyduklarından, bu değeri aşmadığından emin olmalısınız.
