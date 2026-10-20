package com.shopsphere.controller;

import com.shopsphere.model.User;
import com.shopsphere.service.ReviewService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ReviewServlet", urlPatterns = {"/reviews/submit", "/reviews/delete"})
public class ReviewServlet extends HttpServlet {

    private ReviewService reviewService;

    @Override
    public void init() throws ServletException {
        this.reviewService = new ReviewService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if ("/reviews/delete".equals(path)) {
            // Admin review deletion
            if (currentUser.isAdmin()) {
                try {
                    Long reviewId = Long.parseLong(request.getParameter("reviewId"));
                    reviewService.deleteReview(reviewId);
                    session.setAttribute("flashSuccess", "Review removed.");
                } catch (Exception e) {
                    session.setAttribute("flashError", "Failed to delete review: " + e.getMessage());
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/reviews");
            return;
        }

        // Submitting a review
        String prodIdParam = request.getParameter("productId");
        Long productId = null;
        try {
            productId = Long.parseLong(prodIdParam);
            int rating = Integer.parseInt(request.getParameter("rating"));
            String reviewText = request.getParameter("reviewText");

            reviewService.addReview(currentUser.getId(), productId, rating, reviewText);
            session.setAttribute("flashSuccess", "Thank you! Your verified product review has been posted.");

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Error submitting review: " + e.getMessage());
        }

        if (productId != null) {
            response.sendRedirect(request.getContextPath() + "/product?id=" + productId);
        } else {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}
