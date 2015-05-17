<%@page import="healthcare.model.Patient.FriendStatus"%>
<%@page import="healthcare.model.Patient"%>
<%@page import="java.util.ArrayList"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Patient Search Results</title>
    </head>

    <%! ArrayList<Patient> patientList;%>
    <% patientList = (ArrayList<Patient>) request.getAttribute("patientList");%>

    <body>
        <%
            if (patientList != null && !patientList.isEmpty()) {
                out.println("<h1>Patient Search Results</h1>");
                out.println("<table border=1>");
                out.println("<tr><th>Alias</th><th>City</th><th>Province</th><th>Reviews</th><th>Latest Review Data</th><th>Friend Status</th></tr>");
                for (Patient p : patientList) {
                    out.println("<tr><td>");
                    out.println(p.getAlias());
                    out.println("</td><td>");
                    out.println(p.getCity());
                    out.println("</td><td>");
                    out.println(p.getProvince());
                    out.println("</td><td>");
                    out.println(p.getNumReviews());
                    out.println("</td><td>");
                    if (p.getLastReviewDate() != null) {
                        out.println(p.getLastReviewDate());
                    }
                    else {
                        out.println("---");
                    }
                    out.println("</td><td>");

                    if (p.getFriendStatus() == FriendStatus.NONE) {
                        out.println(""
                            + "<form action=\"patient\" method=\"POST\">"
                            + "<input type=\"hidden\" name=\"action\" value=\"add_friend\" />"
                            + "<input type=\"hidden\" name=\"friendAlias\" value=\"" + p.getAlias() + "\" />"
                            + "<input type=\"submit\" value=\"Send Friend Request\" /></form>"
                        );
                    }
                    else if (p.getFriendStatus() == FriendStatus.REQUESTED) {
                        out.println("Request Pending");
                    }
                    else {
                        out.println("Friends");
                    }

                    out.println("</td><tr>");
                }
                out.println("</table>");
            }
            else {
                out.println("<h1>Patient Search Results<h1>");
                out.println("<p>No patients found.<p>");
            }
        %>
        <a href="./">Home</a>
    </body>
</html>
