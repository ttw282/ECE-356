<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Doctor Search</title>
    </head>
    <body>
        <h1>Flexible doctor search</h1>
        <form action="doctor" method="GET">
            <input type="hidden" name="action" value="search">
            <h4>Enter selection criteria:</h4>

            <table>
                <tr>
                    <td>First Name:</td>
                    <td><input type="text" name="fname"></td>
                </tr>
                <tr>
                    <td>Last Name:</td>
                    <td><input type="text" name="lname"></td>
                </tr>
                <tr>
                    <td>Gender:</td>
                    <td>
                        <select name="gender">
                            <option value="Any">Any</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>Address:</td>
                    <td><input type="text" name="addr"></td>
                </tr>
                <tr>
                    <td>City:</td>
                    <td><input type="text" name="city"></td>
                </tr>
                <tr>
                    <td>Province:</td>
                    <td><input type="text" name="prov"></td>
                </tr>
                <tr>
                    <td>Specialization:</td>
                    <td><input type="text" name="spec"></td>
                </tr>
                <tr>
                    <td>Years Licensed:</td>
                    <td><input type="text" name="y_licensed"></td>
                </tr>
                <tr>
                    <td>Rating:</td>
                    <td>
                        <select name="rating">
                            <option value="0">Any</option>
                            <option value="0.5">0.5+</option>
                            <option value="1.0">1.0+</option>
                            <option value="1.5">1.5+</option>
                            <option value="2.0">2.0+</option>
                            <option value="2.5">2.5+</option>
                            <option value="3.0">3.0+</option>
                            <option value="3.5">3.5+</option>
                            <option value="4.0">4.0+</option>
                            <option value="4.5">4.5+</option>
                            <option value="5.0">5.0+</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>Reviewed By Friend:</td>
                    <td><input type="checkbox" name="rb_friend" value="reviewed"></td>
                </tr>
                <tr>
                    <td>Review Containing Keyword: </td>
                    <td><input type="text" name="r_keyword"></td>
                </tr>
            </table>

            <input type="submit" value="Search">
        </form>
    </body>
</html>
