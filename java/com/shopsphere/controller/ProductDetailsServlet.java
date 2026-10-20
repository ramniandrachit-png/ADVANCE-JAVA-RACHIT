package com.shopsphere.controller;

import com.shopsphere.model.Product;
import com.shopsphere.model.Review;
import com.shopsphere.model.User;
import com.shopsphere.service.ProductService;
import com.shopsphere.service.ReviewService;
import com.shopsphere.service.WishlistService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductDetailsServlet", urlPatterns = {"/product"})
public class ProductDetailsServlet extends HttpServlet {

    private ProductService productService;
    private ReviewService reviewService;
    private WishlistService wishlistService;

    @Override
    public void init() throws ServletException {
        this.productService = new ProductService();
        this.reviewService = new ReviewService();
        this.wishlistService = new WishlistService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        try {
            Long productId = Long.parseLong(idParam.trim());
            Product product = productService.getProductById(productId);

            if (product == null || product.getStatus() != Product.Status.ACTIVE) {
                request.getSession().setAttribute("flashError", "The requested product is not available.");
                response.sendRedirect(request.getContextPath() + "/products");
                return;
            }

            // Fetch reviews
            List<Review> reviews = reviewService.getReviewsForProduct(productId);
            List<Product> relatedProducts = productService.getRelatedProducts(productId, product.getCategoryId(), 4);

            // Check wishlist status if user is logged in
            boolean inWishlist = false;
            boolean hasReviewed = false;
            HttpSession session = request.getSession(false);
            if (session != null) {
                User currentUser = (User) session.getAttribute("currentUser");
                if (currentUser != null) {
                    inWishlist = wishlistService.isProductInWishlist(currentUser.getId(), productId);
                    hasReviewed = reviewService.hasUserReviewed(currentUser.getId(), productId);
                }
            }

            request.setAttribute("product", product);
            request.setAttribute("reviews", reviews);
            request.setAttribute("relatedProducts", relatedProducts);
            request.setAttribute("inWishlist", inWishlist);
            request.setAttribute("hasReviewed", hasReviewed);

            request.getRequestDispatcher("/product-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products");
        }
    }
}
