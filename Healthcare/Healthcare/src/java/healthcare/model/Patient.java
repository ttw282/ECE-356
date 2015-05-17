package healthcare.model;

import java.sql.Date;

public class Patient
{
    public enum FriendStatus {
        NONE(0),
        REQUESTED(1),
        FRIENDS(2);

        private int id;
        private FriendStatus(int id)
        {
            this.id = id;
        }

        public static FriendStatus fromInt(int id)
        {
            switch (id) {
                case 0:
                    return NONE;
                case 1:
                    return REQUESTED;
                case 2:
                    return FRIENDS;
                default:
                    return NONE; // Should be more type safe, but meh.
            }
        }
    }

    private String alias;
    private String firstName;
    private String lastName;
    private String city;
    private String province;
    private String email;
    private FriendStatus friendStatus;
    private int numReviews;
    private Date lastReviewDate;

    public Patient(String alias, String firstName, String lastName, String city, String province, String email, int friendStatus)
    {
        this(alias, firstName, lastName, city, province, email, friendStatus, 0, null);
    }

    public Patient(String alias, String firstName, String lastName, String city, String province, String email, int friendStatus, int numReviews, Date lastReviewDate)
    {
        this.alias = alias;
        this.firstName = firstName;
        this.lastName = lastName;
        this.city = city;
        this.province = province;
        this.email = email;
        this.friendStatus = FriendStatus.fromInt(friendStatus);
        this.numReviews = numReviews;
        this.lastReviewDate = lastReviewDate;
    }

    public Patient() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    public String getAlias()
    {
        return alias;
    }

    public void setAlias(String alias)
    {
        this.alias = alias;
    }

    public String getFirstName()
    {
        return firstName;
    }

    public void setFirstName(String firstName)
    {
        this.firstName = firstName;
    }

    public String getLastName()
    {
        return lastName;
    }

    public void setLastName(String lastName)
    {
        this.lastName = lastName;
    }

    public String getCity()
    {
        return city;
    }

    public void setCity(String city)
    {
        this.city = city;
    }

    public String getProvince()
    {
        return province;
    }

    public void setProvince(String province)
    {
        this.province = province;
    }

    public String getEmail()
    {
        return email;
    }

    public void setEmail(String email)
    {
        this.email = email;
    }

    public FriendStatus getFriendStatus()
    {
        return friendStatus;
    }

    public void setFriendStatus(FriendStatus friendStatus)
    {
        this.friendStatus = friendStatus;
    }

    public int getNumReviews()
    {
        return numReviews;
    }

    public void setNumReviews(int numReviews)
    {
        this.numReviews = numReviews;
    }

    public Date getLastReviewDate()
    {
        return lastReviewDate;
    }

    public void setLastReviewDate(Date lastReviewData)
    {
        this.lastReviewDate = lastReviewData;
    }


}
