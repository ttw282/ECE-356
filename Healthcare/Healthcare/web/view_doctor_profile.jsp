<%--
    Document   : view_doctor_profile
    Created on : 23-Mar-2015, 7:22:46 PM
    Author     : tony
--%>

<%@page import="healthcare.model.Review"%>
<%@page import="java.util.ArrayList"%>
<%@page import="healthcare.model.Doctor"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>View doctor profile</title>
    </head>

    <%! Doctor doc;%>
    <% doc = (Doctor) request.getAttribute("doc");%>

    <%! ArrayList<Review> reviews;%>
    <% reviews = (ArrayList<Review>) request.getAttribute("reviews");%>

    <body>
        <h1>Doctor Profile: <%=doc.getFirstName() + " " + doc.getLastName()%></h1>

        <table>
            <tr>
                <td>Alias:</td>
                <td><%=doc.getAlias()%></td>
            </tr>
            <tr>
                <td>First Name:</td>
                <td><%=doc.getFirstName()%></td>
            </tr>
            <tr>
                <td>Last Name:</td>
                <td><%=doc.getLastName()%></td>
            </tr>
            <tr>
                <td>Gender:</td>
                <td><%=doc.getGender()%></td>
            </tr>
            <tr>
                <td>Specializations</td>
                <td><%=doc.getSpecializations()%></td>
            </tr>
            <tr>
                <td>Average Star Rating:</td>
                <td><%=doc.getAvgStarRating()%></td>
            </tr>
            <tr>
                <td>Number Of Reviews:</td>
                <td><%=doc.getNumReviews()%></td>
            </tr>
        </table>

        <form action="patient" method="GET">
            <input type="hidden" name="action" value="write_doc_review_page" />
            <input type="hidden" name="docAlias" value="<%=doc.getAlias()%>" />
            <input type="submit" value="Write review" />
        </form>

        <hr />
        <%

            if (reviews != null && !reviews.isEmpty()) {
                out.println("<h1>Doctor Reviews</h1>");
                out.println("<table border=1>");
                out.println("<tr><th>Reviewed by</th><th>Rating</th><th>Date submitted</th><th>View details</th>");
                for (Review r : reviews) {
                    out.println("<tr><td>");
                    out.print(r.getPatAlias());
                    out.print("</td><td>");
                    out.print(r.getRating());
                    out.print("</td><td>");
                    out.print(r.getDate());
                    out.print("</td><td>");
                    out.println(""
                        + "<form action=\"patient\" method=\"GET\">"
                        + "<input type=\"hidden\" name=\"action\" value=\"view_doctor_review\" />"
                        + "<input type=\"hidden\" name=\"docAlias\" value=\"" + r.getDocAlias() + "\" />"
                        + "<input type=\"hidden\" name=\"id\" value=\"" + r.getId() + "\" />"
                        + "<input type=\"submit\" value=\"View review\" /></form>"
                    );
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            else {
                out.println("No reviews found for this doctor.");
                out.println("<br/>");
            }
        %>
        <a href="./">Home</a>
    </body>
</html>
