package healthcare.servlet;

public class NotAuthenticatedException extends Exception
{
    public NotAuthenticatedException()
    {
    }

    public NotAuthenticatedException(String message)
    {
        super(message);
    }

    public NotAuthenticatedException(Throwable cause)
    {
        super(cause);
    }

    public NotAuthenticatedException(String message, Throwable cause)
    {
        super(message, cause);
    }

}
