# A Small Silly Reminder For Unclosed Session Warning of Hibernate
If you suddenly receive a warning stating "**unclosed connection, forgot to call close() on your Session**" from Hibernate, 
and you are utilizing **OpenSessionInViewFilter** to manage your Hibernate sessions, it is crucial to verify that the filter 
mapping of OpenSessionInViewFilter in **web.xml** precedes any other filter mappings, such as Acegi Security Filters. 
This is particularly important because those other mappings might trigger database operations depending on the Hibernate 
session. If there is no open session, they will likely open one, potentially leaving it open. Normally, it is the 
responsibility of OpenSessionInViewFilter to close Hibernate sessions at the end of the response. 

Just a simple reminder!