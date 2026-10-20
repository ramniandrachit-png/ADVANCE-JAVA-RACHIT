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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Ensures protected customer routes (profile, checkout, orders, wishlist)
 * require an active authenticated user session.
 */
@WebFilter(filterName = "AuthFilter")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser != null && currentUser.getStatus() == User.Status.ACTIVE) {
            chain.doFilter(request, response);
            return;
        }

        // Save requested URL for redirect after successful login
        String requestUri = httpRequest.getRequestURI();
        String queryString = httpRequest.getQueryString();
        String targetUrl = requestUri + (queryString != null ? "?" + queryString : "");
        String encodedTarget = URLEncoder.encode(targetUrl, StandardCharsets.UTF_8);

        // Flash message
        if (session != null) {
            session.setAttribute("flashError", "Please sign in to access this page.");
        }

        httpResponse.sendRedirect(httpRequest.getContextPath() + "/login?redirect=" + encodedTarget);
    }

    @Override
    public void destroy() {
    }
}
