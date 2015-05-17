package healthcare.model;

import java.util.ArrayList;

public class Doctor
{
    public enum Gender {
        Male("male"),
        Female("female"),
        ANY("");

        private String representation;

        private Gender(String representation)
        {
            this.representation = representation;
        }

        public static Gender fromString(String string)
        {
            if ("male".equals(string.toLowerCase())) {
                return Gender.Male;
            }
            else if ("female".equals(string.toLowerCase())) {
                return Gender.Female;
            }
            else {
                return Gender.ANY;
            }
        }

        public String getRepresentation()
        {
            return representation;
        }
    }

    private String alias;
    private String firstName;
    private String lastName;
    private String email;
    private Gender gender;
    private int yearLicensed;
    private double avgStarRating;
    private int numReviews;
    private ArrayList<String> specializations = new ArrayList<String>();
    private ArrayList<String> addresses = new ArrayList<String>();

    public Doctor(String alias, String firstName, String lastName, String email, Gender gender, int yearLicensed)
    {
        this.alias = alias;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.gender = gender;
        this.yearLicensed = yearLicensed;
    }

    public Doctor(String alias, String firstName, String lastName, String email, Gender gender, int yearLicensed, double avgStarRating, int numReviews)
    {
        this.alias = alias;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.gender = gender;
        this.yearLicensed = yearLicensed;
        this.avgStarRating = avgStarRating;
        this.numReviews = numReviews;
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

    public String getEmail()
    {
        return email;
    }

    public void setEmail(String email)
    {
        this.email = email;
    }

    public Gender getGender()
    {
        return gender;
    }

    public void setGender(Gender gender)
    {
        this.gender = gender;
    }

    public int getYearLicensed()
    {
        return yearLicensed;
    }

    public void setYearLicensed(int yearLicensed)
    {
        this.yearLicensed = yearLicensed;
    }

    public double getAvgStarRating()
    {
        return avgStarRating;
    }

    public void setAvgStarRating(double rating)
    {
        this.avgStarRating = rating;
    }

    public void addNumReviews()
    {
        this.numReviews += 1;
    }

    public int getNumReviews(){
        return numReviews;
    }

    public void setNumReviews(int numReviews){
        this.numReviews = numReviews;
    }

    public ArrayList<String> getSpecializations(){
        return specializations;
    }

    public void addSpecialization(String spec){
        specializations.add(spec);
    }

    public ArrayList<String> getAddresses(){
        return addresses;
    }

    public void addAddress(String add){
        addresses.add(add);
    }
}
