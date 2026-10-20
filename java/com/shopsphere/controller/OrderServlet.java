package com.shopsphere.controller;

import com.shopsphere.model.Order;
import com.shopsphere.model.User;
import com.shopsphere.service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "OrderServlet", urlPatterns = {"/orders", "/orders/details", "/orders/success"})
public class OrderServlet extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() throws ServletException {
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

        String path = request.getServletPath();

        if ("/orders/success".equals(path)) {
            String orderNumber = request.getParameter("orderNumber");
            Order order = null;
            if (orderNumber != null && !orderNumber.trim().isEmpty()) {
                order = orderService.getOrderByNumber(orderNumber.trim());
            }
            if (order == null) {
                order = (Order) session.getAttribute("lastPlacedOrder");
            }
            if (order != null && order.getUserId().equals(currentUser.getId())) {
                request.setAttribute("order", order);
                request.getRequestDispatcher("/order-success.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/orders");
            }
            return;
        }

        if ("/orders/details".equals(path)) {
            String idParam = request.getParameter("id");
            String orderNumber = request.getParameter("orderNumber");
            Order order = null;

            if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    order = orderService.getOrderById(Long.parseLong(idParam.trim()));
                } catch (NumberFormatException ignored) {
                }
            } else if (orderNumber != null && !orderNumber.trim().isEmpty()) {
                order = orderService.getOrderByNumber(orderNumber.trim());
            }

            // Security check: ensure order belongs to current user or current user is admin
            if (order != null && (order.getUserId().equals(currentUser.getId()) || currentUser.isAdmin())) {
                request.setAttribute("order", order);
                request.getRequestDispatcher("/order-details.jsp").forward(request, response);
            } else {
                session.setAttribute("flashError", "Order not found or access denied.");
                response.sendRedirect(request.getContextPath() + "/orders");
            }
            return;
        }

        // Default: /orders list
        List<Order> orders = orderService.getOrdersByUser(currentUser.getId());
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }
}
