package healthcare.servlet;

import healthcare.db.HealthcareDBAO;
import healthcare.model.Doctor;
import healthcare.model.Review;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "DoctorServlet", urlPatterns = {"/doctor"})
public class DoctorServlet extends HttpServlet
{
    private boolean authenticated(HttpServletRequest request)
    {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        return (Boolean) session.getAttribute("authenticated");
    }

    private boolean authorized(HttpServletRequest request, String requiredType)
    {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        return requiredType.equals((String) session.getAttribute("type"));
    }

    private String getCurrentUser(HttpServletRequest request) throws ServletException, NotAuthenticatedException, NotAuthorizedException
    {
        return getCurrentUser(request, "Doctor");
    }

    private String getCurrentUser(HttpServletRequest request, String requiredType) throws ServletException, NotAuthenticatedException, NotAuthorizedException
    {
        if (!authenticated(request)) {
            throw new NotAuthenticatedException();
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            throw new ServletException("Unexpected state: Authenticated with session");
        }

        String alias = (String) session.getAttribute("user");
        if (alias == null) {
            throw new NotAuthenticatedException("Unexpected state: Authenticated with no user");
        }

        // Make sure they're a patient
        if (!authorized(request, requiredType)) {
            throw new NotAuthorizedException();
        }

        return alias;
    }

    private void processViewProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String docAlias;
        String url;
        ArrayList<Review> reviews;
        try {
            docAlias = getCurrentUser(request);
            reviews = HealthcareDBAO.getDoctorReviews(docAlias);
            Doctor doc = HealthcareDBAO.patientViewDoctorProfile(docAlias);
            request.setAttribute("doc", doc);
            request.setAttribute("reviews", reviews);
            url = "/doc_view_doc_profile.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "/not_authenticated.jsp";
        }
        catch (NotAuthorizedException ex) {
            url = "/not_authorized.jsp";
        }
        catch (Exception ex) {
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processSearch(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String url;

        try {
            String currentUser = getCurrentUser(request, "Patient");

            // Fields that don't require special sanitization
            String fname = request.getParameter("fname");
            String lname = request.getParameter("lname");
            String address = request.getParameter("addr");
            String city = request.getParameter("city");
            String prov = request.getParameter("prov");
            String spec = request.getParameter("spec");
            String keyword = request.getParameter("r_keyword");

            // These do not require explicit sanatization; front
            // end prohibits invalid data. However, the front-end
            // is non trusted, and values could be bad. However,
            // the use is bad, and we don't care about them for
            // mucking around with the javascript. Will not cause
            // any security concerns.
            double rating = Double.parseDouble(request.getParameter("rating"));
            boolean rbf = request.getParameter("rb_friend") != null;

            // Fields that do require sanitization and/or modification
            int years = Integer.MIN_VALUE;
            if (!request.getParameter("y_licensed").trim().isEmpty()) {
                years = Integer.parseInt(request.getParameter("y_licensed").trim());
            }

            Doctor.Gender gender = Doctor.Gender.fromString(request.getParameter("gender"));

            ArrayList<Doctor> doctors = HealthcareDBAO.doctorSearch(currentUser, fname, lname, gender.getRepresentation(), address, city, prov, spec, years, rating, rbf, keyword);
            request.setAttribute("doctorList", doctors);
            url = "/doctor_search_results.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "/not_authenticated.jsp";
        }
        catch (NotAuthorizedException ex) {
            url = "/not_authorized.jsp";
        }
        catch (NumberFormatException ex) {
            request.setAttribute("field", "Years Licensed");
            request.setAttribute("reason", "Invalid number of years");
            url = "/bad_input.jsp";
        }
        catch (Exception e) {
            request.setAttribute("exception", e);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processViewDoctorReview(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        int reviewId = Integer.parseInt(request.getParameter("id"));
        String docAlias = request.getParameter("docAlias");

        String url;
        try {
            if (!authenticated(request)) {
                throw new NotAuthenticatedException ();
            }
            HealthcareDBAO.viewDoctorReview(reviewId);

            Review r = HealthcareDBAO.viewDoctorReview(reviewId);
            int prevId = HealthcareDBAO.getPrevReviewId(docAlias, reviewId);
            int nextId = HealthcareDBAO.getNextReviewId(docAlias, reviewId);

            request.setAttribute("review", r);
            request.setAttribute("prevId", prevId);
            request.setAttribute("nextId", nextId);
            url = "/view_doc_review.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "/not_authenticated.jsp";
        }
        catch (Exception ex) {
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processGetPage(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String url = request.getParameter("url");

        if ("doctor_search.jsp".equals(url)) {
            if (!authorized(request, "Patient")) {
                url = "not_authorized.jsp";
            }
        }
        // The caller should have checked that we're allowed to get page.
        getServletContext().getRequestDispatcher("/" + url).forward(request, response);
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        String action = request.getParameter("action");
        switch (action) {
            case "get_page":
                processGetPage(request, response);
                break;
            case "profile":
                processViewProfile(request, response);
                break;
            case "search":
                processSearch(request, response);
                break;
            case "view_doc_profile":
                processViewProfile(request, response);
                break;
            case "view_doc_review":
                processViewDoctorReview(request, response);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo()
    {
        return "Short description";
    }// </editor-fold>

}
