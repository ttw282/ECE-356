<%@page import="healthcare.model.Review"%>
<%@page import="java.util.ArrayList"%>
<%@page import="healthcare.model.Doctor"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>View own doctor profile</title>
    </head>

    <%! Doctor doc;%>
    <% doc = (Doctor) request.getAttribute("doc");%>

    <%! ArrayList<Review> reviews;%>
    <% reviews = (ArrayList<Review>) request.getAttribute("reviews");%>

    <body>
        <h1>Your Doctor Profile</h1>
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
                <td>Year Licensed:</td>
                <td><%=doc.getYearLicensed()%></td>
            </tr>
            <tr>
                <td>Gender:</td>
                <td><%=doc.getGender()%></td>
            </tr>
            <tr>
                <%
                    if (doc.getAddresses().isEmpty()) {
                        out.println("<td>Full Address:</td>");
                        out.println("<td>None</td>");
                    }
                    else {
                        for (int i = 0; i < doc.getAddresses().size(); i++) {
                            if (i == 0) {
                                out.println("<td>Full Address:</td>");
                            }
                            else {
                                out.println("<td></td>");
                            }

                            out.println("<td>" + doc.getAddresses().get(i) + "</td>");
                        }
                    }
                %>
            </tr>
            <tr>
                <td>Specializations:</td>
                <td>
                    <%
                        for (int i = 0; i < doc.getSpecializations().size(); i++) {
                            if (i == 0) {
                                out.println(doc.getSpecializations().get(i));
                            }
                            else {
                                out.println(", " + doc.getSpecializations().get(i));
                            }
                        }
                    %>
                </td>
            </tr>
            <tr>
                <td>Average Star Rating:</td>
                <td><%=doc.getAvgStarRating()%></td>
            </tr>
            <tr>
                <td>Number of Reviews:</td>
                <td><%=doc.getNumReviews()%></td>
            </tr>
            <tr>
                <td>Email Address:</td>
                <td><%=doc.getEmail()%></td>
            </tr>
        </table>

        <%
            if (reviews != null) {
                if (reviews.size() != 0) {
                    out.println("<h1>Doctor Reviews</h1>");
                    out.println("<table border=1>");
                    out.println("<tr><th>Reviewed by</th><th>Rating</th><th>Date submitted</th><th>View review</th></tr>");
                    for (Review r : reviews) {
                        out.println("<tr><td>");
                        out.print(r.getPatAlias());
                        out.print("</td><td>");
                        out.print(r.getRating());
                        out.print("</td><td>");
                        out.print(r.getDate());
                        out.print("</td><td>");
                        out.println(""
                            + "<form action=\"doctor\" method=\"GET\">"
                            + "<input type=\"hidden\" name=\"action\" value=\"view_doc_review\" />"
                            + "<input type=\"hidden\" name=\"docAlias\" value=\"" + r.getDocAlias() + "\" />"
                            + "<input type=\"hidden\" name=\"id\" value=\"" + r.getId() + "\" />"
                            + "<input type=\"submit\" value=\"View review\" /></form>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                }
                else {
                    out.println("No reviews found for this doctor.");
                    out.println("<br/>");
                }
            }
        %>
        <a href="./">Home</a>
    </body>
</html>
