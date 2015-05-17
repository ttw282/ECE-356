<%@page import="healthcare.model.Doctor"%>
<%@page import="java.util.ArrayList"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Doctor Search Results</title>
    </head>

    <%! ArrayList<Doctor> doctorList;%>
    <% doctorList = (ArrayList<Doctor>) request.getAttribute("doctorList");%>

    <body>
        <%
            if (doctorList != null && !doctorList.isEmpty()) {
                out.println("<h1>Doctor Search Results</h1>");
                out.println("<table border=1>");
                out.println("<tr><th>Name</th><th>Gender</th><th>Average Rating</th><th>Number of Reviews</th><th>View doctor profile</th></tr>");
                for (Doctor p : doctorList) {
                    out.println("<tr><td>");
                    out.println(p.getFirstName() + " " + p.getLastName());
                    out.println("</td><td>");
                    out.println(p.getGender());
                    out.println("</td><td>");
                    out.println(p.getAvgStarRating());
                    out.println("</td><td>");
                    out.println(p.getNumReviews());
                    out.println("</td><td>");
                    out.println(""
                        + "<form action=\"patient\" method=\"GET\">"
                        + "<input type=\"hidden\" name=\"action\" value=\"view_doctor_profile\" />"
                        + "<input type=\"hidden\" name=\"docAlias\" value=\"" + p.getAlias() + "\" />"
                        + "<input type=\"submit\" value=\"View doctor profile\" /></form>"
                    );
                    out.println("</td></tr>");


                }
                out.println("</table>");
            }
            else {
                out.println("<h1>Doctor Search Results<h1>");
                out.println("<p>No doctors found.<p>");
            }
        %>
        <a href="./">Home</a>
    </body>
</html>
