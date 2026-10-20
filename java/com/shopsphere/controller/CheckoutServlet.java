package com.shopsphere.controller;

import com.shopsphere.dao.AddressDAO;
import com.shopsphere.model.Address;
import com.shopsphere.model.Cart;
import com.shopsphere.model.Coupon;
import com.shopsphere.model.Order;
import com.shopsphere.model.User;
import com.shopsphere.service.CartService;
import com.shopsphere.service.CheckoutService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private CheckoutService checkoutService;
    private CartService cartService;
    private AddressDAO addressDAO;

    @Override
    public void init() throws ServletException {
        this.checkoutService = new CheckoutService();
        this.cartService = new CartService();
        this.addressDAO = new AddressDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=" + request.getContextPath() + "/checkout");
            return;
        }

        Cart cart = cartService.getCart(session, currentUser.getId());
        if (cart == null || cart.getItems().isEmpty()) {
            session.setAttribute("flashError", "Your cart is empty. Add products to continue to checkout.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        // Apply any session coupon to cart
        Coupon appliedCoupon = (Coupon) session.getAttribute("appliedCoupon");
        if (appliedCoupon != null) {
            cart.setAppliedCoupon(appliedCoupon);
        }

        List<Address> addresses = addressDAO.findByUserId(currentUser.getId());
        request.setAttribute("addresses", addresses);
        request.setAttribute("cart", cart);

        // Anti-duplicate submission token
        String checkoutToken = UUID.randomUUID().toString();
        session.setAttribute("checkoutToken", checkoutToken);
        request.setAttribute("checkoutToken", checkoutToken);

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
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

        // Check idempotency token to prevent duplicate order placement
        String submittedToken = request.getParameter("checkoutToken");
        String sessionToken = (String) session.getAttribute("checkoutToken");
        if (submittedToken == null || !submittedToken.equals(sessionToken)) {
            session.setAttribute("flashError", "Order has already been processed or the session expired.");
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }
        // Invalidate token immediately
        session.removeAttribute("checkoutToken");

        try {
            String addressOption = request.getParameter("addressOption");
            Long addressId = null;
            Address newAddress = null;

            if ("new".equalsIgnoreCase(addressOption)) {
                newAddress = new Address();
                newAddress.setRecipientName(request.getParameter("recipientName"));
                newAddress.setPhone(request.getParameter("phone"));
                newAddress.setAddressLine1(request.getParameter("addressLine1"));
                newAddress.setAddressLine2(request.getParameter("addressLine2"));
                newAddress.setCity(request.getParameter("city"));
                newAddress.setState(request.getParameter("state"));
                newAddress.setPostalCode(request.getParameter("postalCode"));
                newAddress.setCountry(request.getParameter("country"));
                newAddress.setDefault("on".equalsIgnoreCase(request.getParameter("saveAsDefault")));
            } else {
                String addrIdParam = request.getParameter("addressId");
                if (addrIdParam != null && !addrIdParam.trim().isEmpty()) {
                    addressId = Long.parseLong(addrIdParam.trim());
                }
            }

            String paymentMethod = request.getParameter("paymentMethod");
            String couponCode = request.getParameter("couponCode");

            Order order = checkoutService.processCheckout(currentUser, addressId, newAddress, paymentMethod, couponCode, session);

            // Clear session coupon
            session.removeAttribute("appliedCoupon");
            session.setAttribute("lastPlacedOrder", order);
            session.setAttribute("flashSuccess", "Thank you! Your order #" + order.getOrderNumber() + " has been placed.");

            response.sendRedirect(request.getContextPath() + "/orders/success?orderNumber=" + order.getOrderNumber());

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout");
        } catch (Exception e) {
            session.setAttribute("flashError", "An unexpected error occurred during checkout: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/checkout");
        }
    }
}
