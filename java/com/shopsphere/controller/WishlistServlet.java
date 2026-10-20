package com.shopsphere.controller;

import com.shopsphere.model.User;
import com.shopsphere.model.WishlistItem;
import com.shopsphere.service.CartService;
import com.shopsphere.service.WishlistService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "WishlistServlet", urlPatterns = {"/wishlist"})
public class WishlistServlet extends HttpServlet {

    private WishlistService wishlistService;
    private CartService cartService;

    @Override
    public void init() throws ServletException {
        this.wishlistService = new WishlistService();
        this.cartService = new CartService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=" + request.getContextPath() + "/wishlist");
            return;
        }

        List<WishlistItem> items = wishlistService.getWishlist(currentUser.getId());
        request.setAttribute("wishlistItems", items);

        request.getRequestDispatcher("/wishlist.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        String returnUrl = request.getParameter("returnUrl");
        if (action == null) action = "";

        try {
            Long productId = Long.parseLong(request.getParameter("productId"));

            switch (action) {
                case "add": {
                    wishlistService.addToWishlist(currentUser.getId(), productId);
                    session.setAttribute("flashSuccess", "Product saved to your wishlist!");
                    break;
                }
                case "remove": {
                    wishlistService.removeFromWishlist(currentUser.getId(), productId);
                    session.setAttribute("flashSuccess", "Product removed from your wishlist.");
                    break;
                }
                case "moveToCart": {
                    cartService.addItem(session, currentUser.getId(), productId, 1);
                    wishlistService.removeFromWishlist(currentUser.getId(), productId);
                    session.setAttribute("flashSuccess", "Product moved from wishlist to your cart!");
                    break;
                }
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Failed to update wishlist: " + e.getMessage());
        }

        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains("://")) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/wishlist");
        }
    }
}
