<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Patient Search</title>
    </head>
    <body>
        <h1>Patient Search</h1>

        <form action="patient" method="POST">
            <input type="hidden" name="action" value="search" />
            <table>
                <tr>
                    <td>Patient Alias:</td>
                    <td><input type="text" name="patAlias" /></td>
                </tr>
                <tr>
                    <td>Province</td>
                    <td><input type="text" name="province" /></td>
                </tr>
                <tr>
                    <td>City</td>
                    <td><input type="text" name="city" /></td>
                </tr>
            </table>

            <br />

            <input type="submit" value="Search">
        </form>
    </body>
</html>
