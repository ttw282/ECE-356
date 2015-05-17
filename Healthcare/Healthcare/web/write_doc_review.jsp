<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Write doctor review</title>
    </head>
        <%! String docAlias;%>
        <%docAlias = (String)request.getAttribute("docAlias");%>
    <body>
        <h1>Write doctor review</h1>
        <form action="patient" method="POST">
            <span>Rating: </span>
            <select name="rating">
                <option value="0.5">0.5</option>
                <option value="1">1</option>
                <option value="1.5">1.5</option>
                <option value="2">2</option>
                <option value="2.5">2.5</option>
                <option value="3">3</option>
                <option value="3.5">3.5</option>
                <option value="4">4</option>
                <option value="4.5">4.5</option>
                <option value="5">5</option>
            </select><br/>
            <span>Comments:</span>
            <textarea type="text" name="comments"></textarea><br/>
            <input type="hidden" name="docAlias" value="<% out.print(docAlias); %>" />
            <input type="hidden" name="action" value="write_doc_review"/>
            <input type="submit" value="Submit">
        </form>
    </body>
</html>
