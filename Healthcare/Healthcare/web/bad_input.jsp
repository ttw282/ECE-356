<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<%! String field;%>
<%! String reason;%>
<% field = (String) request.getAttribute("field");%>
<% reason = (String) request.getAttribute("reason");%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Bad Input</title>
    </head>
    <body>
        <h1>Ban Input for <%=field%> </h1>
        <p><%=reason%></p>
    </body>
</html>
