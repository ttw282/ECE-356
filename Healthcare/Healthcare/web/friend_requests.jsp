<%@page import="healthcare.model.Patient"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Patient view friend requests</title>
    </head>
    <%! ArrayList<Patient> patientList;%>
    <% patientList = (ArrayList<Patient>) request.getAttribute("patientList");%>
    <body>
        <%
            if (patientList != null) {
                if(patientList.size() != 0){
                out.println("<h1>Friend Requests</h1>");
                out.println("<table border=1>");
                out.println("<tr><th>Alias</th><th>Email</th><th>Confirm request</th>");
                for (Patient em : patientList) {
                    out.println("<tr><td>");
                    out.print(em.getAlias());
                    out.print("</td><td>");
                    out.print(em.getEmail());
                    out.print("</td><td>");
                    out.println(""
                        + "<form action=\"patient\" method=\"POST\">"
                        + "<input type=\"hidden\" name=\"action\" value=\"add_friend\" />"
                        + "<input type=\"hidden\" name=\"friendAlias\" value=\"" + em.getAlias() + "\" />"
                        + "<input type=\"submit\" value=\"Confirm Friend Request\" /></form>"
                    );
                }
                out.println("</table>");
                }
                else{
                    out.println("No friend requests found");
                    out.println("<br/>");
                    out.println(" <a href=\"./\">Home</a>");
                }
            }
            %>
    </body>
</html>
