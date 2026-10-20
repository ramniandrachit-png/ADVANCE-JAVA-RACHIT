package com.shopsphere.controller;

import com.shopsphere.model.Cart;
import com.shopsphere.model.Coupon;
import com.shopsphere.model.User;
import com.shopsphere.service.CartService;
import com.shopsphere.service.CouponService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private CartService cartService;
    private CouponService couponService;

    @Override
    public void init() throws ServletException {
        this.cartService = new CartService();
        this.couponService = new CouponService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        User currentUser = (User) session.getAttribute("currentUser");
        Long userId = (currentUser != null) ? currentUser.getId() : null;

        Cart cart = cartService.getCart(session, userId);
        request.setAttribute("cart", cart);

        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);
        User currentUser = (User) session.getAttribute("currentUser");
        Long userId = (currentUser != null) ? currentUser.getId() : null;

        String action = request.getParameter("action");
        String returnUrl = request.getParameter("returnUrl");
        if (action == null) action = "view";

        try {
            switch (action) {
                case "add": {
                    long productId = Long.parseLong(request.getParameter("productId"));
                    int quantity = 1;
                    try {
                        String qtyParam = request.getParameter("quantity");
                        if (qtyParam != null) {
                            quantity = Math.max(1, Integer.parseInt(qtyParam.trim()));
                        }
                    } catch (NumberFormatException ignored) {
                    }
                    cartService.addItem(session, userId, productId, quantity);
                    session.setAttribute("flashSuccess", "Item added to your shopping cart!");
                    break;
                }
                case "update": {
                    long productId = Long.parseLong(request.getParameter("productId"));
                    int quantity = Integer.parseInt(request.getParameter("quantity"));
                    cartService.updateQuantity(session, userId, productId, quantity);
                    session.setAttribute("flashSuccess", "Cart updated successfully.");
                    break;
                }
                case "remove": {
                    long productId = Long.parseLong(request.getParameter("productId"));
                    cartService.removeItem(session, userId, productId);
                    session.setAttribute("flashSuccess", "Item removed from your cart.");
                    break;
                }
                case "clear": {
                    cartService.clearCart(session, userId);
                    session.setAttribute("flashSuccess", "Your shopping cart has been cleared.");
                    break;
                }
                case "applyCoupon": {
                    String code = request.getParameter("couponCode");
                    Cart cart = cartService.getCart(session, userId);
                    Coupon coupon = couponService.validateCoupon(code, cart.getSubtotal());
                    cart.setAppliedCoupon(coupon);
                    session.setAttribute("appliedCoupon", coupon);
                    session.setAttribute("flashSuccess", "Coupon '" + coupon.getCode() + "' applied successfully!");
                    break;
                }
                case "removeCoupon": {
                    Cart cart = cartService.getCart(session, userId);
                    cart.setAppliedCoupon(null);
                    session.removeAttribute("appliedCoupon");
                    session.setAttribute("flashSuccess", "Coupon removed.");
                    break;
                }
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Failed to update cart: " + e.getMessage());
        }

        // Post-Redirect-Get pattern
        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains("://")) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}
