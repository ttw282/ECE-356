package healthcare.servlet;

import healthcare.db.HealthcareDBAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "HomePageServlet", urlPatterns = {"/"})
public class HomePageServlet extends HttpServlet
{
    private boolean authenticated(HttpServletRequest request)
    {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        Boolean b = (Boolean) session.getAttribute("authenticated");
        return (b != null) && b;
    }

    private String getCurrentUser(HttpServletRequest request) throws ServletException, NotAuthenticatedException
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

        return alias;
    }

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        String url;

        try {
            String currentUser = getCurrentUser(request);
            String type = HealthcareDBAO.getUserType(currentUser);

            request.setAttribute("type", type);
            request.setAttribute("user", currentUser);
            url = "/home.jsp";
        }
        catch (NotAuthenticatedException ex) {
            url = "/login.jsp";
        }
        catch (Exception ex) {
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
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
        processRequest(request, response);
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
        processRequest(request, response);
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
