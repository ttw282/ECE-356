package healthcare.model;

import java.sql.*;

public class Review
{
    private int reviewId;
    private String docAlias;
    private String patAlias;
    private String docDisplayName;
    private double rating;
    private Timestamp date;
    private String comments;

    public Review(int reviewId, String docAlias, String patAlias, String docDisplayName, double rating, Timestamp date, String comments)
    {
        this.reviewId = reviewId;
        this.docAlias = docAlias;
        this.patAlias = patAlias;
        this.docDisplayName = docDisplayName;
        this.rating = rating;
        this.date = date;
        this.comments = comments;
    }

    public int getId()
    {
        return this.reviewId;
    }

    public String getDocAlias()
    {
        return docAlias;
    }

    public void setDocAlias(String docAlias)
    {
        this.docAlias = docAlias;
    }

    public String getPatAlias()
    {
        return patAlias;
    }

    public void setPatAlias(String patAlias)
    {
        this.patAlias = patAlias;
    }

    public String getDocDisplayName()
    {
        return docDisplayName;
    }

    public void setDocDisplayName(String docDisplayName)
    {
        this.docDisplayName = docDisplayName;
    }

    public double getRating()
    {
        return rating;
    }

    public void setRating(double rating)
    {
        this.rating = rating;
    }

    public Timestamp getDate()
    {
        return date;
    }

    public void setDate(Timestamp date)
    {
        this.date = date;
    }

    public String getComments()
    {
        return comments;
    }

    public void setComments(String comments)
    {
        this.comments = comments;
    }


}
