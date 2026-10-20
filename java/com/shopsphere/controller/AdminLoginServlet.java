package com.shopsphere.controller;

import com.shopsphere.model.User;
import com.shopsphere.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AdminLoginServlet", urlPatterns = {"/admin/login"})
public class AdminLoginServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null && currentUser.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                return;
            }
        }

        request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User user = userService.authenticate(email, password);

            if (user != null) {
                if (!user.isAdmin()) {
                    request.setAttribute("error", "Access denied. Your account does not have administrator privileges.");
                    request.setAttribute("email", email);
                    request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession(true);
                request.changeSessionId();
                session.setAttribute("currentUser", user);
                session.setAttribute("flashSuccess", "Welcome to Admin Control Center, " + user.getName());

                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                request.setAttribute("error", "Invalid administrator credentials.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Authentication error: " + e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/admin/login.jsp").forward(request, response);
        }
    }
}
