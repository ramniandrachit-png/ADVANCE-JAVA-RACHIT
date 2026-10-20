package com.shopsphere.service;

import com.shopsphere.dao.OrderDAO;
import com.shopsphere.model.Order;

import java.math.BigDecimal;
import java.util.List;

public class OrderService {

    private final OrderDAO orderDAO;

    public OrderService() {
        this.orderDAO = new OrderDAO();
    }

    public OrderService(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
    }

    public Order getOrderById(Long orderId) {
        if (orderId == null || orderId <= 0) return null;
        return orderDAO.findById(orderId);
    }

    public Order getOrderByNumber(String orderNumber) {
        if (orderNumber == null || orderNumber.trim().isEmpty()) return null;
        return orderDAO.findByOrderNumber(orderNumber.trim());
    }

    public List<Order> getOrdersByUser(Long userId) {
        if (userId == null || userId <= 0) return List.of();
        return orderDAO.findByUserId(userId);
    }

    public List<Order> getAllOrdersForAdmin() {
        return orderDAO.findAllForAdmin();
    }

    public boolean updateOrderStatus(Long orderId, Order.OrderStatus status) {
        if (orderId == null || status == null) return false;
        return orderDAO.updateOrderStatus(orderId, status);
    }

    public boolean updatePaymentStatus(Long orderId, Order.PaymentStatus status) {
        if (orderId == null || status == null) return false;
        return orderDAO.updatePaymentStatus(orderId, status);
    }

    public int countTotalOrders() {
        return orderDAO.countTotalOrders();
    }

    public BigDecimal getTotalRevenue() {
        return orderDAO.calculateTotalRevenue();
    }
}
