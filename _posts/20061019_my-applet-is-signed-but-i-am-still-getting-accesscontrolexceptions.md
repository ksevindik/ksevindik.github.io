# My applet is signed, but I am still getting AccessControlExceptions!
We are currently developing a solution that integrates `applets` and web applications together. Our solution includes a 
mechanism to notify `applets` when a user switches from a web page to a page that contains an `applet`. We provide this 
by explicitly invoking a method in `applet` via `JavaScript` when the page is loaded. You may here ask yourself that, why 
we don’t simply make use of `applet` life cycle methods to do this notification. I previously wrote a blog entry about 
that issue, explaining problems with `applet` life cycle methods with `Internet Explorer`. Making use of a `JavaScript` 
which calls a method in `applet` seems the best option currently. In that method, we do some secure operations, hence, 
we need to run the `applet` code as signed in runtime environment. During development cycle, for the sake of simplicity 
we had just modified `java.policy` file, granting permission `java.security.AllPermission` to `applet` codebase. By that 
way there was no need to sign `applet` jar again and again. I personally must admit that I was very confident that our 
solution was going to work in production environment with just signing the `applet` at deployment time. Unfortunately, 
Murphy’s laws always hold, it just didn’t work. I had remembered a clever tip at that time from Pragmatic Programmer’s 
book: Don’t assume it, prove it! Yes, we have to prove even the smallest case in our software, in an environment that is 
as close as to the production environment. A little googling around has revealed the truth; as `Java` plugin cannot verify 
origin of `JavaScript`, which calls method in signed `applet`, it doesn’t give full permissions to this `applet` code. 
This behavior has been introduced in `JDK 1.4.2`. There is actually a still active [discussion](http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=5011139) 
about this restriction on Sun’s site. People criticize Sun as complicating `HTML` to `applet` communication without really 
solving any real security issue. 

Following code just exampling the problem:

```java
public class TestSignApplet extends JApplet {
	public void init() {
        createFile("c:/testsignapplet.txt");
	}

	public void switchToView() {
		createFile("c:/testsignapplet2.txt");
	}

	private void createFile(String filename) {
		FileOutputStream out = null;
		try {
			out = new FileOutputStream(filename);
			out.write(("Testing jar signing process...:" + new Date()).getBytes());
		} catch(Exception ex) {
			ex.printStackTrace();
		} finally  {
			try {
				if(out != null) {
					out.close();
				}
			} catch(IOException e) {}
		}
	}
 }
```
As code is signed before running it in browser, `testsignapplet.txt` file is created in `init()` method without any 
problem, but when `switchToView()` method is called via `JavaScript`, we get `AccessControlException`. Let’s come to our 
solution to this problem. You have actually several options, one is just setting current `SecurityManager` object in 
`System` to null, so that all of the code will get executed with full privileged. We can do this simply with saying 
`System.setSecurityManager(null);` in `init()` method. This approach has a serious drawback, any other third party code 
will also get executed without any security constraint. Second option, afar better approach than the first one, is to 
execute secure operation as a `PrivilegedAction` in the `switchToView()` method. 

The example is as follows:

```java
public void switchToView() {
    AccessController.doPrivileged(new PrivilegedAction() {
	public Object run() {
	    createFile("c:/testsignapplet2.txt");
	    return null;
	}
    });
}
```
