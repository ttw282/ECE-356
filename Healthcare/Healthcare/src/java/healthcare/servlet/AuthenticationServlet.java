package healthcare.servlet;

import healthcare.db.HealthcareDBAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AuthenticationServlet", urlPatterns = {"/authenticate"})
public class AuthenticationServlet extends HttpServlet
{
    private void processLogin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String alias = request.getParameter("alias");
        String password = request.getParameter("password");

        String url;
        try {
            boolean valid = HealthcareDBAO.authenticate(alias, password);
            if (valid) {
                url = "/login_success.jsp";
                request.getSession().setAttribute("user", alias);
                request.getSession().setAttribute("authenticated", true);
                request.getSession().setAttribute("type", HealthcareDBAO.getUserType(alias));
            }
            else {
                url = "/login_failure.jsp";
            }
        }
        catch (Exception ex) {
            request.setAttribute("exception", ex);
            url = "/error.jsp";
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    private void processLogout(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute("user", null);
            session.setAttribute("authenticated", false);
            session.setAttribute("type", null);
        }

        getServletContext().getRequestDispatcher("/logout_success.jsp").forward(request, response);
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
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AuthenticationServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>GET operation is not allowed.</h1>");
            out.println("</body>");
            out.println("</html>");
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
        String action = request.getParameter("action");
        switch (action) {
            case "login":
                processLogin(request, response);
                break;
            case "logout":
                processLogout(request, response);
                break;
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
