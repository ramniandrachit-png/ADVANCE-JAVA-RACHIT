package com.shopsphere.controller;

import com.shopsphere.model.Address;
import com.shopsphere.model.Order;
import com.shopsphere.model.User;
import com.shopsphere.service.AddressService;
import com.shopsphere.service.OrderService;
import com.shopsphere.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private UserService userService;
    private AddressService addressService;
    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService();
        this.addressService = new AddressService();
        this.orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Fetch fresh user data
        User freshUser = userService.getUserById(currentUser.getId());
        if (freshUser != null) {
            currentUser = freshUser;
            session.setAttribute("currentUser", currentUser);
        }

        List<Address> addresses = addressService.getUserAddresses(currentUser.getId());
        List<Order> recentOrders = orderService.getOrdersByUser(currentUser.getId());

        request.setAttribute("user", currentUser);
        request.setAttribute("addresses", addresses);
        request.setAttribute("recentOrders", recentOrders);

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
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
        if (action == null) action = "";

        try {
            switch (action) {
                case "updateDetails": {
                    String name = request.getParameter("name");
                    String phone = request.getParameter("phone");
                    userService.updateProfile(currentUser.getId(), name, phone);
                    currentUser.setName(name);
                    currentUser.setPhone(phone);
                    session.setAttribute("currentUser", currentUser);
                    session.setAttribute("flashSuccess", "Your personal profile details were updated.");
                    break;
                }
                case "changePassword": {
                    String currentPassword = request.getParameter("currentPassword");
                    String newPassword = request.getParameter("newPassword");
                    String confirmPassword = request.getParameter("confirmPassword");
                    if (newPassword == null || !newPassword.equals(confirmPassword)) {
                        throw new IllegalArgumentException("New passwords do not match.");
                    }
                    userService.changePassword(currentUser.getId(), currentPassword, newPassword);
                    session.setAttribute("flashSuccess", "Password changed successfully.");
                    break;
                }
                case "addAddress": {
                    Address address = new Address();
                    address.setUserId(currentUser.getId());
                    address.setRecipientName(request.getParameter("recipientName"));
                    address.setPhone(request.getParameter("phone"));
                    address.setAddressLine1(request.getParameter("addressLine1"));
                    address.setAddressLine2(request.getParameter("addressLine2"));
                    address.setCity(request.getParameter("city"));
                    address.setState(request.getParameter("state"));
                    address.setPostalCode(request.getParameter("postalCode"));
                    address.setCountry(request.getParameter("country"));
                    address.setDefault("on".equalsIgnoreCase(request.getParameter("isDefault")));

                    addressService.addAddress(address);
                    session.setAttribute("flashSuccess", "Delivery address added successfully.");
                    break;
                }
                case "setDefaultAddress": {
                    Long addressId = Long.parseLong(request.getParameter("addressId"));
                    addressService.setDefaultAddress(currentUser.getId(), addressId);
                    session.setAttribute("flashSuccess", "Default address updated.");
                    break;
                }
                case "deleteAddress": {
                    Long addressId = Long.parseLong(request.getParameter("addressId"));
                    addressService.deleteAddress(addressId, currentUser.getId());
                    session.setAttribute("flashSuccess", "Address removed.");
                    break;
                }
                default:
                    break;
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Action failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
