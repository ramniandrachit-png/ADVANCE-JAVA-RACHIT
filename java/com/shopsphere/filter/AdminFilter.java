package com.shopsphere.filter;

import com.shopsphere.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Ensures all /admin/* endpoints are accessible only to authenticated users with Role.ADMIN.
 * Permits public access only to /admin/login and /admin/login.jsp.
 */
@WebFilter(filterName = "AdminFilter")
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        // Allow public admin login endpoints and static assets
        if (path.equals("/admin/login") || path.equals("/admin/login.jsp") 
                || path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser != null && currentUser.isAdmin() && currentUser.getStatus() == User.Status.ACTIVE) {
            chain.doFilter(request, response);
            return;
        }

        // If not authenticated as admin, redirect to admin login
        if (session != null) {
            session.setAttribute("flashError", "Administrator access required. Please sign in with an admin account.");
        }
        httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/login");
    }

    @Override
    public void destroy() {
    }
}
