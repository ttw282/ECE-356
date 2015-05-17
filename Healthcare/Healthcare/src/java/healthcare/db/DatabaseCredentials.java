package healthcare.db;

public enum DatabaseCredentials
{
    NONE("", "", "", ""),
    ECEWEB("eceweb.uwaterloo.ca", "ece356db_mfycheng", "user_mfycheng", "waterloo"),
    TEST("healthcare.weave.network", "healthcare" , "mfycheng", "waterloo");

    private String connectionUrl;
    private String database;
    private String username;
    private String password;

    private DatabaseCredentials(String host, String database, String username, String password)
    {
        this.connectionUrl = "jdbc:mysql://" + host + ":3306/";
        this.database = database;
        this.username = username;
        this.password = password;
    }

    public String getConnectionUrl()
    {
        return connectionUrl;
    }

    public String getDatabase()
    {
        return database;
    }

    public String getUsername()
    {
        return username;
    }

    public String getPassword()
    {
        return password;
    }
}
