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
import java.util.List;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin/users"})
public class AdminUserServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<User> users = userService.getAllUsers();
        request.setAttribute("users", users);

        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String action = request.getParameter("action");
        if ("toggleStatus".equals(action)) {
            try {
                Long targetUserId = Long.parseLong(request.getParameter("userId"));
                if (currentUser != null && currentUser.getId().equals(targetUserId)) {
                    session.setAttribute("flashError", "You cannot suspend your own administrator account.");
                } else {
                    boolean updated = userService.toggleUserStatus(targetUserId);
                    if (updated) {
                        session.setAttribute("flashSuccess", "User account status toggled successfully.");
                    } else {
                        session.setAttribute("flashError", "Failed to update user status.");
                    }
                }
            } catch (Exception e) {
                session.setAttribute("flashError", "Error: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
