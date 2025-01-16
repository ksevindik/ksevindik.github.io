# Providing Tooltip Help Messages Dynamically Using Ajax Functionality
This is actually part of context-sensitive help requirements in our web application project. We should be able to provide 
small informative messages for HTML components, displaying them as tooltips on our web pages when the user moves the mouse 
over those components.

It is also a requirement that continuously appearing tooltip message windows on those pages, along with mouse movement, 
shouldn’t be disruptive to the user. Hence, we let the user determine the time of tooltip message appearance by pressing 
`CTRL` while moving the mouse over components, which will enable tooltip message appearance.

We should further be able to change the content of tooltip messages and add new tooltip messages for other components 
without any source code modification.

Our solution has two parts: one on the client side, employing JavaScript to fetch any available tooltip messages from the 
server-side using Ajax functionality for currently focused HTML components (via `CTRL` + mouse over at this time) and 
displaying them by opening a `DIV` element as a tooltip message container, positioning it near the bottom right corner of 
the related component.

On the server side, there is a `HelpServlet` employed as an Ajax service endpoint, returning tooltip messages according 
to given HTML component IDs. The tooltip message solution is closely related to our other part of the context-sensitive 
help mechanism, as they both employ page help context IDs together with component IDs. The reason for this is that we 
need unique tooltip message identifiers across the whole web application in order to identify each component’s tooltip 
message. As a result, we concatenate the page help context ID together with the HTML component ID and use it as a key for 
the component’s tooltip message. We then ask `HelpServlet` with that key if there is any available tooltip message for 
the currently focused component.

Tooltip messages on the server side are kept in a message properties file and loaded at startup time by `HelpServlet`.

Below is the client-side JavaScript code:

```javascript
var appContextPath  = '/webAppContext;
var helpServletPath = '/helpServlet';
var http;

function getPageHelpContextID() {
    var pageCtxObj = document.getElementById('form1:pageCtxId');
    if(pageCtxObj) {
        return pageCtxObj.value;
    } else {
        return document.forms[0].id;
    }
}

function showToolTip(evt) {
    evt = (evt)?evt:event;
    
    if(evt.ctrlKey) {
        var element = (evt.target)?evt.target:evt.srcElement;
        
        var toolTipElement = document.getElementById('toolTip');
        if(!toolTipElement) {
        
            toolTipElement = document.createElement('div');
            toolTipElement.id = 'toolTip';
            toolTipElement.style.position='absolute';
            toolTipElement.style.zIndex=1;
            toolTipElement.style.backgroundColor= '#FFFF99';
            toolTipElement.style.width=200;
            toolTipElement.style.height=30;
            toolTipElement.style.borderStyle='solid';
            toolTipElement.style.borderColor='#CCCCCC';
            toolTipElement.style.borderWidth='1px';
            
            document.body.appendChild(toolTipElement);
        }
            
        toolTipElement.style.left=findPosX(element) + element.offsetWidth + 10;
        toolTipElement.style.top=findPosY(element) + element.offsetHeight + 10;
        
        fetchAndDisplayToolTipMsg(element.id);
    }    
}

function hideToolTip(evt) {
    evt = (evt)?evt:event;
    var element = (evt.target)?evt.target:evt.srcElement;
    var toolTipElement = document.getElementById('toolTip');
    if(toolTipElement)
        toolTipElement.style.visibility='hidden';
}

function findPosX(obj) {
    var curleft = 0;
    if (obj.offsetParent) {
        while (obj.offsetParent) {
            curleft += obj.offsetLeft
            obj = obj.offsetParent;
        }
    }
    else if (obj.x)
        curleft += obj.x;
    return curleft;
}

function findPosY(obj) {
    var curtop = 0;
    if (obj.offsetParent) {
        while (obj.offsetParent) {
            curtop += obj.offsetTop
            obj = obj.offsetParent;
        }
    }
    else if (obj.y)
        curtop += obj.y;
    return curtop;
}

function fetchAndDisplayToolTipMsg(msgId) {
    if(msgId) {
        http = createHttpRequestObject();
        sendHttpRequest(getPageHelpContextID() + ':' + msgId);
    }
}

function createHttpRequestObject() {
    var ro;
       if(window.ActiveXObject) {
        ro = new ActiveXObject("Microsoft.XMLHTTP");
    }else{
        ro = new XMLHttpRequest();
    }
    return ro;
}

function sendHttpRequest(toolTipMsgId) {
    http.open('get', appContextPath + helpServletPath +'?toolTipMsgId=' + escape(toolTipMsgId),true);
    http.onreadystatechange = handleHttpResponse;
    http.send(null);
}

function handleHttpResponse() {
    if(http.readyState == 4) {
        var toolTipElement = document.getElementById('toolTip');
        
        var msg = http.responseText;
        
        if(msg && (msg.length > 0)) {
            toolTipElement.innerText = msg;
            toolTipElement.style.visibility='visible';
        }
        
    }
}
```

In order to activate the above functionality, we must add two event handlers in the `BODY` HTML element as follows:

```html
<BODY onmouseover="showToolTip(event);" onmouseout="hideToolTip(event);" ...>
...
</BODY>
```
As you see above, the main entry points are `showToolTip()` and `hideToolTip()` functions which are called on mouse over 
and mouse out events accordingly. In `showToolTip()`, we first create a `DIV` element to display tooltip messages in it 
if it hasn’t been created before, then we fetch the tooltip message for the current component from the server-side via 
`XmlHttpRequest`, and finally display it by placing any available tooltip message into the `DIV` element.

And here below is the excerpt from the server-side `HelpServlet`:

```java
protected void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {
    String toolTipMsgId = getToolTipMessageId(request);
    String msg = getToolTipMessage(toolTipMsgId);
    returnToolTipMessage(response, msg);
}
    
private void returnToolTipMessage(HttpServletResponse response, String msg)  throws IOException, UnsupportedEncodingException {
    if(StringUtils.isNotEmpty(msg)) {
        response.setContentType("text/plain");
        OutputStream out = response.getOutputStream();
        response.setContentLength(msg.getBytes("utf-8").length);
        out.write(msg.getBytes("utf-8"));
        out.close();
    }
}

private String getToolTipMessage(String toolTipMsgId) {
    String msg = toolTipMessageProperties.getProperty(toolTipMsgId);
    return msg;
}

private String getToolTipMessageId(HttpServletRequest request) {
    String toolTipMsgId = request.getParameter("toolTipMsgId");
    return toolTipMsgId;
}
```
As you see above, we get the `toolTipMsgId` parameter value from the request, and look up the corresponding tooltip message 
value in the properties file. Finally, if there is an existing tooltip message for the component, we return that message 
as plain text through the servlet response.
