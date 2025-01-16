# Cactus XOR Mocks or Cactus AND Mocks?
We employ both Spring and Hibernate to implement the business and data access layers in our current project. Our aim is 
to bring clear separation between those two layers. Beans in the business layer act as service entry points; they simply 
realize our use case scenarios. They are also good candidates as start and endpoints for business transactions and 
authorization-level security checks to allow or deny users who attempt to execute the business logic.

Testability is our main concern as well, and actually, I want to bring the discussion to that specific point. We have 
clearly separated layers, and each of those layers should be tested in isolation. Unit testing using mock objects or using 
Cactus to run tests in a container appears as two distinct alternatives at first glance. For example, the business logic 
in our service layer objects is tested simply by mocking data access layer objects. But things get a little bit complicated 
when it comes to testing those required behaviors while security and transactional contexts are available. We need to 
provide an environment in which those two middleware services should be up and running or provide the test base with their 
mock implementations at least. This is obviously a difficult task, and things could get more complicated if our system 
depends more and more on such components.

Assume that we provided our system with those required services or their mock implementations, but we could never be sure 
that our system acts as if it were in a real production environment. Another point with this kind of unit testing is that 
our tests could be so fine-grained that we never see any interactions between objects in different layers. Each object is 
tested in isolation from other dependent objects. For example, when we test service objects in the business layer, we only 
check the business logic in them. We do not hit real data access objects and the database either. This may not seem to be 
a problem, but anyway we cannot be one hundred percent sure that our system will work as a whole in the target environment.

I think Cactus, an in-container testing framework, relieves us from the problems/difficulties mentioned in the above 
paragraphs. I actually do not see using Cactus to do in-container testing and testing with mock objects as opponents but 
complementary to each other. Cactus tests appear more as integration unit tests, while mock objects are used mainly in 
testing business logic in isolation.