# Ivy: Agile Dependency Management Tool

In my opinion, `Ivy` is the best dependency management tool compared to others in the field. Unfortunately, good things 
don’t always receive enough interest they deserve from the developer community. `Ivy` shares the same destiny in this 
respect.

I have been using `Ivy` together with `Ant` to build Java projects for more than 2 years, and I must express my 
satisfaction with what it provides as a dependency management tool; resolving transitive dependencies, evicting old 
libraries, synchronizing target folders, publishing released artifacts are the ones I use a lot among many other features.

`Ivy` had joined into `Apache Incubation` several months ago and it has recently graduated as a sub-project of `Ant`. 
Until yesterday, I was using version `1.4.1` which was the latest stable release available before its join into incubation, 
and waiting for a stable release, during which its team had only provided two alpha releases. To confess, I had hesitated 
to upgrade to one of those alpha releases in case I might lose the current stability of my development platform. Last 
night I gave a quick decision not to wait for a final `2.0.0` release and perform the upgrade immediately. Within one 
hour, the upgrade was over and I found myself enjoying features I sought for a long time! The upgrade consists mainly of 
renaming some XML elements and changing XML namespace in ant build files. It is actually backward compatible with `1.4.1` 
release, so you don’t have to change anything if you don’t mind seeing some deprecation messages.

`Ivy` is usually miscompared against `Maven` which actually claims to provide more than what `Ivy` alone tries to achieve, 
and when compared in terms of dependency management features they are usually not examined very carefully.

For example, in `Maven` feature comparison [page](http://docs.codehaus.org/display/MAVEN/Feature+Comparisons), 
it is stated that both tools are capable of excluding dependencies from 
the tree, and are able to apply a version globally. Unfortunately, nobody will know in which plates those features are 
served up until they use any of them! In `Maven`, when you want to exclude some transitive dependencies from your 
project’s classpath, you still need to know by which dependency they are introduced into, and enlist them exactly in all 
of those dependency elements in your `pom.xml`. There is no patternized way to specify what to exclude in your `pom`. On 
the other hand, in `Ivy`, you can easily enlist excluded dependencies without knowing from which dependency it comes. You 
can even use regular expressions to specify them.

One other silly feature of `Maven` is that it keeps version suffixes of dependencies when it copies them into the target 
folder. I still can’t believe it doesn’t provide a feature to strip off version suffixes of dependencies, but within its 
poor documentation, I couldn’t have found relevant info so far. Unless you build your project with a clean option, you 
might easily end up with having different versions of the same library in your deployment. You can even face this problem 
while you still perform your build with a clean option, during deploying your project into an application server. For 
example, in `Eclipse`, `Tomcat` web container just copies your project's war content into its temporary area, and if you 
only publish your project without cleaning its temporary area you will end up with the same problem mentioned above. It 
might be a trivial issue to perform clean operations before building and deploying the project, but as you see, there is 
an obvious friction here during developing software. `Ivy` avoids such a problem by simply stripping off version suffixes 
when copying them into the target folder.

A similar problem repeats when you remove a dependency from your list; it should also be removed from target folders, too. 
`Ivy` has a sync feature for this. It will remove any of the unlisted jars from your target folder.

Finally, I want to add for the people who want to use `Ivy`, but restrain themselves because of `Ivy` repository support 
around the net, that `Ivy` is able to utilize existing `Maven` repositories.
