<%@page import="healthcare.model.Review"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%! Review review;%>
<% review = (Review) request.getAttribute("review");%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Doctor Review</title>
    </head>

    <%! Review r;%>
    <%! int prevId;%>
    <%! int nextId;%>

    <% r = (Review) request.getAttribute("review");%>
    <% prevId = (Integer) request.getAttribute("prevId");%>
    <% nextId = (Integer) request.getAttribute("nextId");%>

    <body>
        <h1>Review for <%=review.getDocDisplayName()%></h1>
        <table>
            <tr>
                <td>Date: </td>
                <td><%=review.getDate()%></td>
            </tr>
            <tr>
                <td>Reviewed by:</td>
                <td><%=review.getPatAlias()%></td>
            </tr>
            <tr>
                <td>Rating: </td>
                <td><%=review.getRating()%></td>
            </tr>
            <tr>
                <td>Comment: </td>
                <td><textarea readonly><%=review.getComments()%></textarea></td>
            </tr>
        </table>

        <% if (prevId >= 0) {
                out.print(""
                    + "<form action=\"patient\" method=\"GET\" style=\"display: inline;\">"
                    + "<input type=\"hidden\" name=\"action\" value=\"view_doctor_review\" />"
                    + "<input type=\"hidden\" name=\"docAlias\" value=\"" + r.getDocAlias() + "\" />"
                    + "<input type=\"hidden\" name=\"id\" value=\"" + prevId + "\" />"
                    + "<input type=\"submit\" value=\"Previous\" /></form>"
                );
            }
            if (nextId >= 0) {
                out.print(""
                    + "<form action=\"patient\" method=\"GET\" style=\"display: inline;\">"
                    + "<input type=\"hidden\" name=\"action\" value=\"view_doctor_review\" />"
                    + "<input type=\"hidden\" name=\"docAlias\" value=\"" + r.getDocAlias() + "\" />"
                    + "<input type=\"hidden\" name=\"id\" value=\"" + nextId + "\" />"
                    + "<input type=\"submit\" value=\"Next\" /></form>"
                );
            }
        %>

    </body>
</html>
