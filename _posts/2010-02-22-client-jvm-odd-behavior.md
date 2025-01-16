# Client JVM Odd Behavior

Last week, a collegue of mine came and showed an odd behavior of JRE. It applies to both JRE 1.5.0_14 and 1.6.0_02. Here 
is the test code:

If we run above test code in client JVM, then we get output as follows:

```console
Elapsed Time: 2219Elapsed Time: 1109
```

When we comment out the line 15, new Integer(10); at the beginning of test method, and then run again in client JVM, the 
results becomes:

```console
Elapsed Time: 2218Elapsed Time: 14093
```

Huh! What is going on here? We only instantiated an Integer before running those other two long running loops. When we 
run above code in server JVM with or without commented line, result becomes as follows:

```console
Elapsed Time: 1375Elapsed Time: 750
Elapsed Time: 1359Elapsed Time: 750
```

This time, nothing happens unexpected.

In short, I suspected with client and server JVMs’ garbage collection behaviors, and performed same tests with `-verbose:gc 
VM parameter in order to see how long does GC take. However number of GCs, and execution time of each doesn’t differ for 
client JVM in both cases. Server JVM’s GC count are much fewer than client JVM as expected.

Is there someone who can comment about what is going on with client JVM in this case?