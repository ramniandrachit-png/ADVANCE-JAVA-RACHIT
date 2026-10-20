package com.shopsphere.controller;

import com.shopsphere.model.Order;
import com.shopsphere.service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders"})
public class AdminOrderServlet extends HttpServlet {

    private OrderService orderService;

    @Override
    public void init() throws ServletException {
        this.orderService = new OrderService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderIdParam = request.getParameter("id");
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                Long orderId = Long.parseLong(orderIdParam.trim());
                Order order = orderService.getOrderById(orderId);
                request.setAttribute("selectedOrder", order);
            } catch (NumberFormatException ignored) {
            }
        }

        List<Order> orders = orderService.getAllOrdersForAdmin();
        request.setAttribute("orders", orders);

        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            Long orderId = Long.parseLong(request.getParameter("orderId"));

            if ("updateStatus".equals(action)) {
                String newStatusStr = request.getParameter("orderStatus");
                Order.OrderStatus newStatus = Order.OrderStatus.valueOf(newStatusStr);
                orderService.updateOrderStatus(orderId, newStatus);
                session.setAttribute("flashSuccess", "Order #" + orderId + " status updated to " + newStatus);
            } else if ("updatePayment".equals(action)) {
                String newPaymentStr = request.getParameter("paymentStatus");
                Order.PaymentStatus paymentStatus = Order.PaymentStatus.valueOf(newPaymentStr);
                orderService.updatePaymentStatus(orderId, paymentStatus);
                session.setAttribute("flashSuccess", "Order #" + orderId + " payment status updated to " + paymentStatus);
            }
        } catch (Exception e) {
            session.setAttribute("flashError", "Failed to update order: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }
}
