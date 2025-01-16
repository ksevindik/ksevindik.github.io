# Running Eclipse Ganymede in Ubuntu Karmic Koala

I wouldn't guess it would be that hard to install Eclipse 3.4.2 Ganymede in Ubuntu 9.10 Karmic Koala. After searching a 
bit around the web, I concluded that it was not the way to go with `sudo apt-get install eclipse` this time.

Then I downloaded 3.4.2 from the [Eclipse site](http://eclipse.ulak.net.tr/eclipseMirror/technology/epp/downloads/release/ganymede/SR2/eclipse-jee-ganymede-SR2-linux-gtk.tar.gz), 
extracted it, and started playing with it. The first command trial was 
`./eclipse`. After issuing this command, Eclipse failed with an empty dialog after showing the splash screen in a few 
seconds. Googling around the net revealed that I should run it with the `-vm` argument or by putting it into `eclipse.ini` 
to avoid typing it later on:

```bash
./eclipse -vm /usr/java/jdk1.6.0_17/bin/java
```

After showing the splash screen, Eclipse failed again, but this time an error dialog showed where to find the cause of 
the error: `/home/ksevindik/workspace/.metadata/.log`.

```stacktrace
org.eclipse.swt.SWTError: XPCOM error -2147467259
at org.eclipse.swt.browser.Mozilla.error(Mozilla.java:1638)
at org.eclipse.swt.browser.Mozilla.create(Mozilla.java:312)
at org.eclipse.swt.browser.Browser.<init>(Browser.java:118)
```

Uh! Again, I needed to refer to Google for it. This time, I found a page suggesting to first install xulrunner with:

```bash
sudo apt-get install xulrunner
```

Then, I needed to add the following line into `eclipse.ini`:

```ini
-Dorg.eclipse.swt.browser.XULRunnerPath=/usr/lib/xulrunner/xulrunner
```

Bingo! Eclipse starts now without any error, at least for the moment...



