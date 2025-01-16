# Acegi-JSF 1.1.3 is released
It was over a year ago that `Çağatay` developed some [JSF components](http://cagataycivici.wordpress.com/2006/01/19/acegi_jsf_components_hit_the/) 
which correspond to Acegi JSP taglib. We were in the same project at that time and were using Acegi Security Framework 
extensively. Later, our ways were separated, and we focused on different tasks.

Recently, I started work on a new project to enable Acegi Security within portal environments. The result is the
[Acegi Security Extensions Project](http://acegi-ext.sourceforge.net/) in which a solution for acegi portlet integration 
exists. During that project, I developed sample portlets with JSF to illustrate the use of Acegi and wanted to employ 
`acegi-jsf` components in them.

Unfortunately, `acegi-jsf` 1.1.2 was dependent on the `HttpServletRequest` object to identify an authenticated user. As 
there is no notion of `HttpServletRequest` within portlets, a modification was needed for `acegi-jsf`. The 
[1.1.3 release](http://sourceforge.net/project/showfiles.php?group_id=137466) is out with this modification. From now on, 
`acegi-jsf` doesn’t depend on `HttpServletRequest` and can work in portlet environments as well.

Furthermore, with this arrangement, you don’t have to configure `SecurityContextHolderAwareRequestFilter` in the filter 
chain of your Acegi security configuration in your normal web applications. `Çağatay` had already mentioned it to be fixed 
in release 1.2, but I decided not to do a major version increment for those fixes as there is no major change in the use 
of components. All changes occurred behind the component interfaces, so your JSF pages don’t need any change to work with 
the new release.
