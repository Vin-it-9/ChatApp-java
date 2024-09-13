package model;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (username == null || username.isEmpty() || email == null || email.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (UserDAO.userExists(username, email)) {
            request.setAttribute("errorMessage", "Username or email already exists.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        boolean isRegistered = UserDAO.registerUser(username, email, password);

        if (isRegistered) {

            response.sendRedirect("login.jsp");

        } else {

            request.setAttribute("errorMessage", "Registration failed, please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);

        }
    }
}
