package com.shopsphere.controller;

import com.shopsphere.model.User;
import com.shopsphere.service.CartService;
import com.shopsphere.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private UserService userService;
    private CartService cartService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService();
        this.cartService = new CartService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String redirect = request.getParameter("redirect");
        request.setAttribute("redirect", redirect);
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        try {
            User user = userService.authenticate(email, password);

            if (user != null) {
                // Prevent session fixation by generating a fresh session ID
                HttpSession session = request.getSession(true);
                request.changeSessionId();

                session.setAttribute("currentUser", user);
                session.setAttribute("flashSuccess", "Welcome back, " + user.getName() + "!");

                // Sync session cart with persistent DB cart
                try {
                    cartService.syncCartOnLogin(session, user.getId());
                } catch (Exception ignored) {
                }

                // If user is admin and logging in, offer direct link or redirect if they were accessing admin
                if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("://")) {
                    response.sendRedirect(redirect);
                } else if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/");
                }
            } else {
                request.setAttribute("error", "Invalid email address or password.");
                request.setAttribute("email", email);
                request.setAttribute("redirect", redirect);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } catch (IllegalStateException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("email", email);
            request.setAttribute("redirect", redirect);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An unexpected error occurred during sign-in.");
            request.setAttribute("email", email);
            request.setAttribute("redirect", redirect);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
