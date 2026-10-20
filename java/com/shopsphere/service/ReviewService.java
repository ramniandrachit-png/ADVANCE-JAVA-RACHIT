package com.shopsphere.service;

import com.shopsphere.dao.ReviewDAO;
import com.shopsphere.model.Review;

import java.util.List;

public class ReviewService {

    private final ReviewDAO reviewDAO;

    public ReviewService() {
        this.reviewDAO = new ReviewDAO();
    }

    public ReviewService(ReviewDAO reviewDAO) {
        this.reviewDAO = reviewDAO;
    }

    public List<Review> getReviewsForProduct(Long productId) {
        if (productId == null || productId <= 0) return List.of();
        return reviewDAO.findByProductId(productId);
    }

    public boolean hasUserReviewed(Long userId, Long productId) {
        if (userId == null || productId == null) return false;
        return reviewDAO.hasUserReviewedProduct(userId, productId);
    }

    public Review addReview(Long userId, Long productId, int rating, String reviewText) {
        if (userId == null || productId == null) {
            throw new IllegalArgumentException("Invalid user or product.");
        }
        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5 stars.");
        }
        if (reviewText == null || reviewText.trim().isEmpty()) {
            throw new IllegalArgumentException("Review text cannot be empty.");
        }
        if (reviewDAO.hasUserReviewedProduct(userId, productId)) {
            throw new IllegalArgumentException("You have already reviewed this product.");
        }

        Review review = new Review();
        review.setUserId(userId);
        review.setProductId(productId);
        review.setRating(rating);
        review.setReviewText(reviewText.trim());

        boolean created = reviewDAO.create(review);
        if (created) {
            return review;
        }
        throw new IllegalStateException("Failed to submit review.");
    }

    public boolean deleteReview(Long reviewId) {
        if (reviewId == null || reviewId <= 0) return false;
        return reviewDAO.delete(reviewId);
    }

    public List<Review> getAllReviewsForAdmin() {
        return reviewDAO.findAllForAdmin();
    }
}
