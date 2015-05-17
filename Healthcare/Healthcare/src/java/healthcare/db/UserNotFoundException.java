package healthcare.db;

public class UserNotFoundException extends DatabaseException
{
    public UserNotFoundException(String message)
    {
        super(message);
    }

    public UserNotFoundException(Throwable cause)
    {
        super(cause);
    }

    public UserNotFoundException(String message, Throwable cause)
    {
        super(message, cause);
    }

}
