# TestContainers  & MySQL Setup Notes

Integration tests are one of the fundamental building blocks of the testing pyramid. By using integration tests, we try 
to verify if our software components interact with each other and with their third-party external dependencies according 
to the requirements of the software being written. One type of those external dependencies is called 
**generic third-party dependencies**, which indicate they are used in the same manner across different software products 
continuously. MySQL database, Kafka broker, Elasticsearch, or Redis server dependencies are among those generic third-party 
dependencies.

It is very important how efficiently we bootstrap and manage those third-party external dependencies while executing our 
tests in our development and test environments. One of the options to manage them is to use embedded versions as 
alternatives to them. For example, if our software system already makes use of ORM technology, we would employ an embedded 
database alternative even if our database vendor differs in the production environment. Similarly, we can employ embedded 
Kafka or embedded Redis solutions within our integration tests. However, sometimes we may need to bootstrap and employ 
the exact same type of server while running the tests, because our code might have server-specific pieces in it, such as 
vendor-specific DB constructs like functions, stored procedures, and so on. Therefore, we need a similar way to run those 
generic third-party dependencies without causing any interference among different tests running at the same time. 
**TestContainers** solution follows this way, which is based on Docker containers. I will show you how to configure 
**TestContainers** with the MySQL setup in particular, in order to run those server instances inside the containers so 
that our integration tests can utilize them.

So what do we need to achieve this? First of all, we need to install Docker Container on the computer. Afterward, we can 
proceed with the adding following dependencies into the gradle build file.

```kotlin
    implementation(platform("org.testcontainers:testcontainers-bom:1.15.3"))
    testImplementation("org.testcontainers:testcontainers")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:mysql:1.15.3")
```

After this step, we can place the `@Testcontainers` annotation on top of our integration test class. It will help us to 
automatically start and stop containers while our tests are running. It scans attributes annotated with the `@Container` 
annotation and invokes their lifecycle methods so that container instances are started and stopped according to the test 
execution. It is possible to define attributes as either instance or static variables. The below definition is static as 
it is placed within the companion object block which is the static counterpart in Kotlin language.

```kotlin
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.MySQLContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers

@SpringBootTest
@Testcontainers
abstract class BaseIntegrationTests {
    companion object {
        @Container
        private val mySQLContainer = MySQLContainer<Nothing>("mysql:5.7.33").apply {
            this.withDatabaseName("my-db-name")
            this.withUsername("sa")
            this.withPassword("secret")
            this.withConnectTimeoutSeconds(10 * 60)
        }.start()

        @JvmStatic
        @DynamicPropertySource
        fun dbProperties(registry: DynamicPropertyRegistry) {
            registry.add("spring.datasource.driver-class-name") { "com.mysql.cj.jdbc.Driver" }
            registry.add("spring.datasource.url", mySQLContainer::getJdbcUrl)
            registry.add("spring.datasource.jdbcUrl", mySQLContainer::getJdbcUrl)
            registry.add("spring.datasource.password", mySQLContainer::getPassword)
            registry.add("spring.datasource.username", mySQLContainer::getUsername)
            registry.add("spring.jpa.hibernate.database-platform") { "org.hibernate.dialect.MySQL57Dialect" }
        }
    }
}
```

After the container definition, we need to provide MySQL DB-specific JDBC properties with the application. For that purpose, 
Spring provides **DynamicPropertyRegistry** capability so that we can define related JDBC property values by obtaining 
them from the MySQL container which has just been created. The `@DynamicPropertySource` annotation marks the method within 
which such property definitions or overrides take place. This method is invoked during the Spring `ApplicationContext` 
bootstrap process.

If defined as static, the container will be started only once before all tests are run, and stopped after finishing 
execution of all tests. In other words, that container instance will be shared across several test cases. This is called 
**shared mode**.

When we use a MySQL TestContainer in shared mode, we need to take care of test fixture cleanup at the end of each test 
method execution. If we mark test methods as `@Transactional`, then Spring will take care of it, as it rolls back the 
transaction at the end of each test method. However, in the case of a test method where no transaction exists, we will 
need to do it ourselves. For this purpose, we can develop something similar below to delete all the data in our test 
database instance after the execution of each test method.

```kotlin
    @Autowired
    private lateinit var jdbcTemplate: JdbcTemplate
    
    @AfterEach
    fun deleteAllData() {
        jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 0")
        val queryForList = jdbcTemplate.queryForList(
            """SELECT concat('DELETE FROM `', table_name, '`;')
                    FROM information_schema.tables
                    WHERE table_schema = 'my-db-name';""",
            String::class.java
        )
        queryForList.forEach {
            jdbcTemplate.execute(it)
        }
        jdbcTemplate.execute("SET FOREIGN_KEY_CHECKS = 1")
    }
```

As a final word, according to Testcontainers documentation, TestContainers usage has only been tested with sequential 
test execution, and it may have unintended effects in case they are run in parallel.