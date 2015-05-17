<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Health Cares</title>
    </head>
    <%! String user;%>
    <%! String type;%>


    <% user = (String) request.getAttribute("user");%>
    <% type = (String) request.getAttribute("type");%>
    <%out.println("Logged in as " + user);
    %>
    <body>
        <h1>Please select one of the following:</h1>
        <ul>

        <%
            if("Doctor".equals(type)){
                out.println("<li><a href=\"doctor?action=view_doc_profile\">View Doctor Profile</a></li>");
            }
        %>

        <%
            if ("Patient".equals(type)) {
                out.println("<li><a href=\"patient?action=get_page&url=patient_search.jsp\">Patient Search</a></li>");
                out.println("<li><a href=\"patient?action=friend_requests\">Patient view friend requests</a></li>");
                out.println("<li><a href=\"doctor?action=get_page&url=doctor_search.jsp\">Flexible doctor search</a></li>");
            }
        %>

        </ul>

        <form id="logout" action="authenticate" method="POST">
            <input type="hidden" name="action" value="logout" />
        </form>

        <a href="javascript:{}" onclick="document.getElementById('logout').submit(); return false;">Logout</a>

    </body>
</html>
