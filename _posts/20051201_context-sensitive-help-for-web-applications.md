# Context Sensitive Help For Web Applications

Providing help topics relevant to current usage scenarios is a demanding requirement in today’s enterprise web applications. 
It is generally called as context-sensitive help. Those help systems should automatically navigate to relevant help topics 
in help windows according to the current business process, the current web page, or the currently focused component on 
those pages.

There are similar requirements in our current web project. It should basically provide help for a focused component on a 
web page if there exists any available help topic for that component. If there isn’t any for that component, then it should 
automatically navigate to the current web page’s help section or the business process’s one.

We implemented the above requirements employing JavaScript, IE’s built-in onHelp event handler, and a simple Ajax 
functionality to retrieve available tooltip messages from the server-side without refreshing the whole web page.

When someone presses F1, our help window should be opened instead of Microsoft IE’s built-in help window. It’s currently 
achievable easily by implementing the onHelp event handler in the body HTML element as below, for example;
```html
<BODY onHelp="openHelp(); return false"...>
...
</BODY>
```
In the openHelp method, we open a new browser window, displaying the related help topic:
```javascript
function openHelp() {
        helpUrl = 'help.html';
        helpUrl += '#' + getPageHelpContextID();

        if(document.activeElement && (document.activeElement.id.length > 0)) 
{
            helpUrl += ':' + document.activeElement.id;
        }

helpWin = window.open(helpUrl,'Help','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=1,width=600,height=700');
        setTimeout('helpWin.focus();',250);
}

function getPageHelpContextID() {
        var pageCtxObj = document.getElementById('form1:pageCtxId');
        if(pageCtxObj) {
            return pageCtxObj.value;
        } else {
            return document.forms[0].id;
        }
}
```
It first gets the current page’s help context ID, which is provided via a hidden HTML input element. This value must be 
unique across the application’s help context. The page’s form ID, if it is unique enough, could also be used as the help 
context ID. This page help context ID is appended to the end of helpUrl. It then looks at the active element in the current 
HTML document. If there exists a focused (active) HTML component in the current document and if it has an HTML ID attribute, 
then that ID is also appended to the end of helpUrl. We can easily focus on any component on a web page navigating via the 
TAB key. Finally, a new window is opened by calling window.open() with giving helpURL as input parameter into it.

The above section tries to explain how to enable context-sensitive help mechanism in the web application. The other side 
of the coin is to develop help content and to keep it synchronized with the web application’s page and component structure.

One of the most important points is to use the same identifiers, defined inside web pages, across the help content as those 
pages’ and their components’ help section IDs. Basically, those component IDs are used as anchor names in help pages. 
Therefore, full coordination between software developers and help content providers must exist during the development life 
cycle.
