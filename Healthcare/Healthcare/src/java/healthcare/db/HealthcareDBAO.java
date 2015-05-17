package healthcare.db;

import healthcare.model.Doctor;
import healthcare.model.Patient;
import healthcare.model.Review;
import static java.lang.Double.parseDouble;
import static java.lang.Integer.parseInt;
import java.sql.*;
import java.util.ArrayList;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class HealthcareDBAO {

    private static DatabaseCredentials credentials = DatabaseCredentials.TEST;

    private static Connection getConnection() throws NamingException, SQLException {
        InitialContext cxt = new InitialContext();
        if (cxt == null) {
            throw new RuntimeException("Unable to create naming context!");
        }
        Context dbContext = (Context) cxt.lookup("java:comp/env");
        DataSource ds = (DataSource) dbContext.lookup("jdbc/myDatasource");
        if (ds == null) {
            throw new RuntimeException("Data source not found!");
        }
        return ds.getConnection();
    }

    public static void testConnection() throws NamingException, SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public static void resetDatabase() throws NamingException, SQLException {
        Connection conn = null;
        CallableStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call Test_ResetDB() }");

            stmt.execute();
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

    public static boolean authenticate(String alias, String password) throws NamingException, SQLException {
        Connection conn = null;
        CallableStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call authenticate(?, ?, ?) }");
            stmt.setString(1, alias);
            stmt.setString(2, password);
            stmt.registerOutParameter(3, Types.BOOLEAN);

            stmt.execute();

            boolean successful = stmt.getBoolean("valid");

            return successful;
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

    public static String getUserType(String alias) throws NamingException, SQLException, UserNotFoundException {
        Connection conn = null;
        CallableStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call GetUserType(?, ?) }");
            stmt.setString(1, alias);
            stmt.registerOutParameter(2, Types.TINYINT);

            stmt.execute();

            int retVal = stmt.getInt("retVal");
            if (retVal == 1) {
                return "Patient";
            } else if (retVal == 2) {
                return "Doctor";
            } else {
                throw new UserNotFoundException("While determining user type for: " + alias);
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            } else {
                conn.close();
            }
        }
    }

    public static ArrayList<Patient> patientSearch(String currentAlias, String patAlias, String province, String city) throws NamingException, SQLException {
        Connection conn = null;
        CallableStatement stmt = null;
        ArrayList<Patient> ret = new ArrayList<>();

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call PatientSearch(?, ?, ?, ?) }");

            stmt.setString(1, currentAlias);
            stmt.setString(2, "%" + patAlias + "%");
            stmt.setString(3, "%" + province + "%");
            stmt.setString(4, "%" + city + "%");

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Patient p = new Patient(
                        rs.getString("patAlias"),
                        rs.getString("firstName"),
                        rs.getString("lastName"),
                        rs.getString("city"),
                        rs.getString("province"),
                        rs.getString("patEmail"),
                        rs.getInt("friendStatus"),
                        rs.getInt("numReviews"),
                        rs.getDate("lastestReviewDate"));

                ret.add(p);
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return ret;
    }

    public static ArrayList<Doctor> doctorSearch(String currentUser, String fname, String lname, String gender, String address, String city, String prov, String spec, int years, double rating, boolean rbf, String keyword) throws NamingException, SQLException {
        Connection conn = null;
        CallableStatement stmt = null;
        ArrayList<Doctor> ret = new ArrayList<>();

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call DoctorSearch(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) }");

            stmt.setString(1, currentUser);
            stmt.setString(2, "%" + fname + "%");
            stmt.setString(3, "%" + lname + "%");
            stmt.setString(4, "%" + spec + "%");
            stmt.setString(5, gender + "%"); // Don't have wildcard in front, male will match female
            stmt.setString(6, "%" + address + "%");
            stmt.setString(7, "%" + city + "%");
            stmt.setString(8, "%" + prov + "%");
            stmt.setInt(9, years);
            stmt.setDouble(10, rating);
            if (rbf) {
                stmt.setInt(11, 0);
            } else {
                stmt.setInt(11, 1);
            }
            stmt.setBoolean(11, rbf);
            stmt.setString(12, "%" + keyword + "%");

            String s = stmt.toString();
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                //Doctor(String alias, String firstName, String lastName, String email, Gender gender, int yearLicensed)
                Doctor d = new Doctor(
                        rs.getString("docAlias"),
                        rs.getString("firstName"),
                        rs.getString("lastName"),
                        rs.getString("docEmail"),
                        "male".equals(rs.getString("gender")) ? Doctor.Gender.Male : Doctor.Gender.Female,
                        rs.getInt("yearLicensed"),
                        rs.getDouble("avgRating"),
                        rs.getInt("numReviews"));

                ret.add(d);
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return ret;
    }

    public static boolean addFriend(String adderAlias, String addeeAlias) throws NamingException, SQLException, DatabaseException {
        Connection conn = null;
        CallableStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call AddFriend(?, ?, ?) }");
            stmt.setString(1, adderAlias);
            stmt.setString(2, addeeAlias);
            stmt.registerOutParameter(3, Types.TINYINT);

            stmt.execute();

            int retVal = stmt.getInt("retVal");

            if (retVal == -1) {
                throw new UserNotFoundException(adderAlias + " does not exist");
            } else if (retVal == -2) {
                throw new UserNotFoundException(addeeAlias + " does not exist");
            } else if (retVal == 1) {
                // Not a bi-directinoal relationship; not a friendship
                return false;
            } else if (retVal == 2) {
                // Bi-directional relationship; friendship
                return true;
            } else {
                throw new DatabaseException("Unknown return value");
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

    public static ArrayList<Patient> patientViewFriendRequests(String patAlias) throws NamingException, SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ArrayList<Patient> ret = new ArrayList<>();

        String query = "SELECT * FROM Patient P "
                + "RIGHT JOIN ( "
                + "    SELECT A.patAlias FROM SocialNetwork AS A "
                + "    WHERE A.friendAlias = ? "
                + "    AND A.patAlias NOT IN ( "
                + "        SELECT B.friendAlias FROM SocialNetwork as B "
                + "        WHERE B.patAlias = ? "
                + "    ) "
                + ") AS C "
                + "ON C.patAlias = P.patAlias";

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(query);

            stmt.setString(1, patAlias);
            stmt.setString(2, patAlias);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Patient p = new Patient(
                        rs.getString("patAlias"),
                        rs.getString("firstName"),
                        rs.getString("lastName"),
                        rs.getString("city"),
                        rs.getString("province"),
                        rs.getString("patEmail"),
                        1 // Every friend here is in the request stage
                        );

                ret.add(p);
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return ret;
    }

    public static Doctor patientViewDoctorProfile(String docAlias) throws NamingException, SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        Doctor ret = null;

        String query = "SELECT D.docAlias, S.field, D.docEmail, D.firstName, D.lastName, D.gender, A.address, A.city, A.province, A.postalCode, D.yearLicensed, AVG(R.rating) AS \"avgRating\", "
                + "COUNT(DISTINCT(R.reviewId)) AS \"numReviews\" FROM Doctor D "
                + "LEFT JOIN Review R ON R.docAlias = D.docAlias "
                + "INNER JOIN Address A ON A.docAlias = D.docAlias "
                + "INNER JOIN DoctorSpec DS ON DS.docAlias = D.docAlias "
                + "INNER JOIN Specialization S ON S.specId = DS.specId "
                + "WHERE D.docAlias = ? "
                + "GROUP BY D.docAlias, D.docEmail, S.field, D.firstName, D.lastName, D.gender, A.address, A.city, A.province, A.postalCode, D.yearLicensed;";

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(query);

            stmt.setString(1, docAlias);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                if (ret == null) {
                    ret = new Doctor(
                            rs.getString("docAlias"),
                            rs.getString("firstName"),
                            rs.getString("lastName"),
                            rs.getString("docEmail"),
                            Doctor.Gender.fromString(rs.getString("gender")),
                            parseInt(rs.getString("yearLicensed")),
                            (rs.getString("avgRating") != null) ? parseDouble(rs.getString("avgRating")) : 0,
                            rs.getInt("numReviews"));
                }

                String field = rs.getString("field");
                String fullAddress = rs.getString("address") + " " + rs.getString("city") + " " + rs.getString("province") + " " + rs.getString("postalCode");
                if (!ret.getSpecializations().contains(field)) {
                    ret.addSpecialization(field);
                }
                if (!ret.getAddresses().contains(fullAddress)) {
                    ret.addAddress(fullAddress);
                }
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return ret;
    }

    public static ArrayList<Review> getDoctorReviews(String docAlias) throws NamingException, SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ArrayList<Review> ret = new ArrayList<>();

        String query = ""
                + "SELECT * "
                + "FROM Review R "
                + "LEFT JOIN Doctor D ON D.docAlias = R.docAlias "
                + "WHERE R.docAlias = ? "
                + "ORDER BY submitDate DESC";

        try {
            conn = getConnection();
            stmt = conn.prepareStatement(query);

            stmt.setString(1, docAlias);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Review r = new Review(
                        rs.getInt("reviewId"),
                        rs.getString("docAlias"),
                        rs.getString("patAlias"),
                        rs.getString("firstName") + " " + rs.getString("lastName"),
                        rs.getDouble("rating"),
                        rs.getTimestamp("submitDate"),
                        rs.getString("comments"));
                ret.add(r);
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return ret;
    }

    public static void writeDocReview(String docAlias, String patAlias, double rating, String comments) throws NamingException, SQLException, DatabaseException {
        Connection conn = null;
        CallableStatement stmt = null;

        try {
            conn = getConnection();
            stmt = conn.prepareCall("{ call WriteDoctorReview(?, ?, ?, ?) }");
            stmt.setString(1, patAlias);
            stmt.setString(2, docAlias);
            stmt.setDouble(3, rating);
            stmt.setString(4, comments);

            stmt.execute();
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

    public static Review viewDoctorReview(int reviewId) throws NamingException, SQLException, DatabaseException {
        Connection conn = null;
        PreparedStatement stmt = null;
        Review r = null;
        try {
            conn = getConnection();
            stmt = conn.prepareStatement(""
                    + "SELECT *"
                    + "FROM Review R "
                    + "JOIN Doctor D ON R.docAlias = D.docAlias "
                    + "WHERE reviewId = ?");
            stmt.setInt(1, reviewId);

            ResultSet rs = stmt.executeQuery();
            if (!rs.next()) {
                return null;
            }

            return new Review(
                    rs.getInt("reviewId"),
                    rs.getString("docAlias"),
                    rs.getString("patAlias"),
                    rs.getString("firstName") + " " + rs.getString("lastName"),
                    rs.getDouble("rating"),
                    rs.getTimestamp("submitDate"),
                    rs.getString("comments"));
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
    }

    public static int getPrevReviewId(String docAlias, int currentReviewId) throws NamingException, SQLException, DatabaseException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            String query = ""
                    + "SELECT *"
                    + "FROM Review "
                    + "WHERE reviewId < ? "
                    + "AND docAlias = ? "
                    + "ORDER BY reviewId DESC "
                    + "LIMIT 1 ";

            conn = getConnection();
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, currentReviewId);
            stmt.setString(2, docAlias);

            ResultSet r = stmt.executeQuery();
            if (r.next()) {
                return r.getInt("reviewId");
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return -1;
    }

    public static int getNextReviewId(String docAlias, int currentReviewId) throws NamingException, SQLException, DatabaseException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            String query = ""
                    + "SELECT *"
                    + "FROM Review "
                    + "WHERE reviewId > ? "
                    + "AND docAlias = ? "
                    + "ORDER BY reviewId ASC "
                    + "LIMIT 1 ";

            conn = getConnection();
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, currentReviewId);
            stmt.setString(2, docAlias);

            ResultSet r = stmt.executeQuery();
            if (r.next()) {
                return r.getInt("reviewId");
            }
        } finally {
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        }

        return -1;
    }
}
