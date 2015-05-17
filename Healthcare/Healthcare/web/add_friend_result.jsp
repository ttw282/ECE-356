<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Friend Request</title>
    </head>

    <%! boolean friends;%>
    <% friends = (Boolean) request.getAttribute("friends");%>

    <body>
        <% if (friends) {
            out.println("<h1>Friend Request: Accepted</h1>");
            out.println("<h1>You are now friends!</h1>");
        }
        else {
            out.println("<h1>Friend Request: Successful</h1>");
            out.println("<p>Pending friends acceptance.<p>");
        }
        out.println("<a href=\"./\">Home</a>");
        %>
    </body>
</html>
