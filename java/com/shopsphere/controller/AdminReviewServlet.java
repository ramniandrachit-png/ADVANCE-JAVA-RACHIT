package com.shopsphere.controller;

import com.shopsphere.model.Review;
import com.shopsphere.service.ReviewService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminReviewServlet", urlPatterns = {"/admin/reviews"})
public class AdminReviewServlet extends HttpServlet {

    private ReviewService reviewService;

    @Override
    public void init() throws ServletException {
        this.reviewService = new ReviewService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Review> reviews = reviewService.getAllReviewsForAdmin();
        request.setAttribute("reviews", reviews);

        request.getRequestDispatcher("/admin/reviews.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            try {
                Long reviewId = Long.parseLong(request.getParameter("reviewId"));
                reviewService.deleteReview(reviewId);
                session.setAttribute("flashSuccess", "Review was removed by administrator.");
            } catch (Exception e) {
                session.setAttribute("flashError", "Failed to delete review: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/reviews");
    }
}
