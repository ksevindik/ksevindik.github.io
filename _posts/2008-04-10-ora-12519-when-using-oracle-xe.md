# ORA-12519 When Using Oracle XE

I recently installed `Oracle XE` on my laptop and tried to run our project which normally uses `Oracle 10g` in our company. 
After creating a db user and enabling it, I created tables, sequences, triggers, and stored procedures, etc., by running 
db init scripts through `ant` without any problem. When it came to starting the application in the application server, I 
got "**ORA-12519, TNS:no appropriate service handler found**" messages. Thanks to this and this blog entries to reach a quick 
solution. The problem was a bug in how `Oracle XE` handles monitoring processes, and you need to execute 
"**ALTER SYSTEM SET PROCESSES=150 SCOPE=SPFILE;**" statement and then restart your database to get rid of it.

After overcoming this problem, I came up with a Turkish character encoding problem within my `Hibernate` generated SQL 
statements, but I am not hundred percent sure if I installed `Oracle XE` to deal with non-latin characters appropriately. 
Anyway, it is easy to get rid of such encoding problems by setting `user.language` and `user.country` system properties 
to "en" and "US" consecutively.
