<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login</title>
    </head>
    <body>
        <h1>Login</h1>
        <form action="/Healthcare/authenticate" method="POST">
            <input type="hidden" name="action" value="login" />
            <table>
                <tr>
                    <td>Alias:</td>
                    <td><input type="text" name="alias" /></td>
                </tr>
                <tr>
                    <td>Password</td>
                    <td><input type="password" name="password" /></td>
                </tr>
            </table>
            <input type="submit" name="submit" value="Login" />
        </form>
    </body>
</html>
