# Some Thoughts About Constant Interface (Anti)Pattern
I have recently restarted to read ***Effective Java Programming Language*** book written by Joshua Bloch. Actually, I had 
skimmed it several times before, but had no chance to cover it from beginning to end yet. I want to express some of my 
thoughts about **Item 17: *Use interfaces only to define types***. In this item, he states that the ***constant interface pattern*** 
is a poor use of interfaces. As we employ it in our current project, I had some fresh observations about that (anti)pattern. 
I think many people just employ this pattern in order to get rid of putting class names in front of constants while 
accessing them, and to collect and group those constants just in one construct, in order to easily find and access all 
available definitions in code base. Those are valid reasons for our project, too. Otherwise, it gets very difficult to 
remember which constant is defined in which class or interface, and it also gets more and more difficult to give consistent 
names and values to those constants if they are not easily accessible to examine just in one place. Joshua Bloch lists his 
counter arguments in his book as follows.

* First of all, it causes a leakage of implementation detail into many unrelated classes in your code base, because any of 
the defined constant will be available to all of your classes when they implement this interface. 
* As it is contained in the exported API of implementing class, clients of that class may get easily confused because it if 
of no consequence to the users of the class that it implements such an interface. 
* Finally, it puts you into a commitment to ensure binary compatibility in the future, even though the class won’t need to 
use any of those constants.

I mostly agree with Josh’s arguments here. Benefits of not introducing above anomalies into your code far more outweighs 
than just getting rid of typing class names in front of constants. I personally observed that one can easily make use of 
any unrelated constant in his client class. At the end it is a good idea to collect all of the constants in one place 
and make them accessible to every other class or interface in your code base, and it is much better to create a 
noninstantiable constant class and to put all of your constants with consistent naming conventions both for variables 
and for their values into it.
