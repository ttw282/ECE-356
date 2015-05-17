package healthcare.db;

public class DatabaseException extends Exception
{
    public DatabaseException(String message)
    {
        super(message);
    }

    public DatabaseException(String message, Throwable cause)
    {
        super(message, cause);
    }

    public DatabaseException(Throwable cause)
    {
        super(cause);
    }

}
