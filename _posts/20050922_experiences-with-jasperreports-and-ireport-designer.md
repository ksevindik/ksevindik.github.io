# Experiences with JasperReports and iReport Designer
JasperReports employs the concept of subreporting to handle complex report template requests, dividing the main part into 
logically related and more manageable smaller subreport chunks. For example, if a report includes a section where a list 
of data items appears as a data table, that section is a natural candidate for a subreport. The table column labels are 
placed into the column header band, and each cell field value is placed into the detail band. This subreport is then 
inserted into the master report in place of the data table.

Another usage pattern of subreports is to group related report elements to reduce complexity in the master report. 
Certain report elements appearing in the master report and related to each other in some way can be moved into a 
subreport.

Yet another usage is the conditional insertion of different report content according to the current report data. For 
instance, a report design may have parts that differ based on conditions such as type, state, or other data attributes. 
Each conditional branch is designed as a distinct subreport and inserted into the master report when the specified 
condition holds true for the current report data.

All of the above usage patterns indicate that master reports and subreports share many aspects related to report design. 
For instance, report parameters or variables defined in the master report might also be reused in subreports. Additionally, 
report labels used in all reports, including master and subreports, may be read from a resource bundle. Therefore, a 
single global definition of a resource bundle should be sufficient for all related reports.

Unfortunately, you cannot group and reuse those parameters, variables, or resource bundle definitions in all related 
reports. Therefore, you have to add resource bundle definitions repeatedly in all subreports. Report import directives 
and font definitions are not propagated either. This is because, in JasperReports, subreports are treated as normal 
master reports.

We extensively used subreporting to group related report elements and conditionally insert these groups into the master 
report. For example, we had a master report consisting of six major related data sections, each of which had alternatives 
that could replace each other depending on the report data. We designed each section as a subreport, and these subreports 
also contained additional subreports. Initially, each subreport in the master report was placed into the detail band, but 
the sections did not appear in the proper sequence. For instance, a section that could fit into the remaining page area 
of another section was drawn, although it should have been the last section in the report output. We addressed this issue 
by creating group elements for each subreport separately and placing each subreport into a group header band. The height 
of the detail band and group footer was reduced to zero pixels. As a result, each section in the report output appeared 
in the proper sequence. Creating groups somehow seemed like a "Silver Bullet" in our JasperReport designs!

We also solved another problem by applying subreporting and groups. In this case, we had a report with some text field 
elements, each drawn row by row, followed by a subreport element used to display tabular list data that might span several 
pages. In this scenario, JasperReports left a space equal to the total height of the text elements preceding the tabular 
list data section on each subsequent report page. We placed the tabular list section into a separate group element and 
the first section containing text field elements into another group. This way, the full height of subsequent report pages 
was used for rendering the remaining tabular list data during report output generation.

Many people agree that many reports in enterprise projects contain tabular data to display, necessitating special support 
for constructing tables in report design. Unfortunately, JasperReports lacks a notion of table construct. Instead, you 
need to use textField elements to create tables. Each cell, including column labels, becomes a textField element with 
solid borders. Care must be taken not to make adjacent sides of textFields solid, as this can result in some lines 
appearing thicker than others in your tables. You must use the elementGroup report element to group each textField cell 
so that they can stretch as much as the highest cell in each table row. iReport currently fails to keep up with 
JasperReports releases, and its current version does not support elementGroup. We had to modify its source code to add 
elementGroup support in the iReport designer.

Exporting to HTML format also presents some crucial problems. Firstly, it is generated with absolute pixel-by-pixel 
widths of HTML elements, resulting in HTML pages that do not look good on every screen resolution and browser size. 
Additionally, we were unable to achieve exactly the same report output with PDF and HTML formats. While the PDF format 
generally looks better, it also has some minor bugs.

Ideally, we should be able to export HTML output to a temporary file destination specified with java.io.File. For example, 
we could generate report output and save it to a file, which would be automatically removed when the JVM terminates. This 
is easily possible with the JDK IO API, but the JasperExportManager API currently only accepts string filenames as report 
output destinations, not java.io.File input parameters.