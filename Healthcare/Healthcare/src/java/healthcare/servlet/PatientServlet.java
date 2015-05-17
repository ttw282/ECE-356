package healthcare.servlet;

import healthcare.db.HealthcareDBAO;
import healthcare.db.UserNotFoundException;
import healthcare.model.Doctor;
import healthcare.model.Patient;
import healthcare.model.Review;
import java.io.IOException;
import static java.lang.Double.parseDouble;
import static java.lang.Integer.parseInt;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "PatientServlet", urlPatterns = {"/patient"})
public class PatientServlet extends HttpServlet
{
    private boolean authenticated(HttpServletRequest request)
    {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        Boolean b = (Boolean) session.getAttribute("authenticated");
        return (b != null) && b.booleanValue();
    }

    private boolean authorized(HttpServletRequest request)
    {
        return authorized(request, "Patient");
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
        if (!authorized(request)) {
            throw new NotAuthorizedException();
        }

        return alias;
    }

    private void processSearch(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String alias = request.getParameter("patAlias");
        String city = request.getParameter("city");
        String province = request.getParameter("province");

        String url;

        try {
            ArrayList<Patient> patients = HealthcareDBAO.patientSearch(getCurrentUser(request), alias, province, city);
            request.setAttribute("patientList", patients);
            url = "/patient_search_results.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "/not_authenticated.jsp";
        }
        catch (NotAuthorizedException ex) {
            url = "/not_authorized.jsp";
        }
        catch (Exception ex) {
            // TODO: Exception
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processGetFriendRequests(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String url;
        try {
            ArrayList<Patient> friendsRequests = HealthcareDBAO.patientViewFriendRequests(getCurrentUser(request));
            request.setAttribute("patientList", friendsRequests);
            url = "/friend_requests.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "/not_authenticated.jsp";
        }
        catch (NotAuthorizedException ex) {
            url = "/not_authorized.jsp";
        }
        catch (Exception e) {
            // TODO: Exception
            request.setAttribute("exception", e);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processAddFriend(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String addee = request.getParameter("friendAlias");

        String url;
        try {
            boolean friends = HealthcareDBAO.addFriend(getCurrentUser(request), addee);
            request.setAttribute("friends", friends);
            url = "/add_friend_result.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "./not_authenticated.jsp";
        }
        catch (UserNotFoundException ex) {
            // TODO: error page
            url = "/user_not_found.jsp";
        }
        catch (Exception ex) {
            // TODO: generic exception
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processViewDoctorProfile(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String docAlias = request.getParameter("docAlias");
        ArrayList<Review> reviews = new ArrayList<Review>();
        String url;
        try {
            Doctor doc = HealthcareDBAO.patientViewDoctorProfile(docAlias);
            reviews = HealthcareDBAO.getDoctorReviews(docAlias);
            request.setAttribute("doc", doc);
            request.setAttribute("reviews", reviews);
            url = "/view_doctor_profile.jsp";
        }
        catch (Exception ex) {
            // TODO: generic exception
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processWriteDocReviewPage(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String docAlias = request.getParameter("docAlias");

        String url;
        try {
            request.setAttribute("docAlias", docAlias);
            url = "/write_doc_review.jsp";
        }
        catch (Exception ex) {
            // TODO: generic exception
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void writeDocReview(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        //String docAlias = request.getParameter("docAlias");
        double rating = parseDouble(request.getParameter("rating"));
        String comments = request.getParameter("comments");
        String docAlias = request.getParameter("docAlias");

        String url;
        try {
            HealthcareDBAO.writeDocReview(docAlias, getCurrentUser(request), rating, comments);
            url = "/view_doctor_profile.jsp";
            processViewDoctorProfile(request, response);
        }
        catch (NotAuthenticatedException ex) {
            request.setAttribute("exception", ex);
            url = "./not_authenticated.jsp";
        }
        catch (Exception ex) {
            // TODO: generic exception
            request.setAttribute("exception", ex);
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
            Review r = HealthcareDBAO.viewDoctorReview(reviewId);

            int prevId = HealthcareDBAO.getPrevReviewId(docAlias, reviewId);
            int nextId = HealthcareDBAO.getNextReviewId(docAlias, reviewId);

            request.setAttribute("review", r);
            request.setAttribute("prevId", prevId);
            request.setAttribute("nextId", nextId);

            url = "/view_doc_review.jsp";
        }
        catch (Exception ex) {
            // TODO: generic exception
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processGetPage(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
    {
        String url;

        // The caller should have checked that we're allowed to get page.
        getServletContext().getRequestDispatcher("/" + request.getParameter("url")).forward(request, response);
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
        // Every page is protected that goes through here
        String failUrl = null;
        if (!authenticated(request)) {
            failUrl = "/not_authenticated.jsp";
        }

        if (failUrl == null) {
            String action = request.getParameter("action");
            switch (action) {
                case "get_page":
                    if (!authorized(request)) {
                        failUrl = "/not_authorized.jsp";
                        break;
                    }
                    else {
                        processGetPage(request, response);
                        return;
                    }
                case "friend_requests":
                    if (!authorized(request)) {
                        failUrl = "/not_authorized.jsp";
                        break;
                    }
                    else {
                        processGetFriendRequests(request, response);
                        return;
                    }
                case "view_doctor_profile":
                    if (!authorized(request)) {
                        failUrl = "/not_authorized.jsp";
                        break;
                    }
                    else {
                        processViewDoctorProfile(request, response);
                        return;
                    }
                case "view_doctor_review":
                    // No need to authenticate for review
                    processViewDoctorReview(request, response);
                    break;
                case "write_doc_review_page":
                    if (!authorized(request)) {
                        failUrl = "/not_authorized.jsp";
                        break;
                    }
                    else {
                        processWriteDocReviewPage(request, response);
                        return;
                    }
            }
        }

        getServletContext().getRequestDispatcher(failUrl).forward(request, response);
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
        // Every page is protected that goes through here
        String failUrl = null;
        if (!authenticated(request)) {
            failUrl = "/not_authenticated.jsp";
        }
        else if (!authorized(request)) {
            failUrl = "/not_authorized.jsp";
        }

        if (failUrl != null) {
            getServletContext().getRequestDispatcher(failUrl).forward(request, response);
        }
        else {
            String action = request.getParameter("action");
            switch (action) {
                case "search":
                    processSearch(request, response);
                    break;
                case "add_friend":
                    processAddFriend(request, response);
                    break;
                case "write_doc_review":
                    writeDocReview(request, response);
            }
        }
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
