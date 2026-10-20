package com.shopsphere.dao;

import com.shopsphere.model.Order;
import com.shopsphere.model.OrderItem;
import com.shopsphere.model.Payment;
import com.shopsphere.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrderDAO {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    public Order findById(Long id) {
        String sql = "SELECT o.*, u.name AS user_name, u.email AS user_email " +
                     "FROM orders o " +
                     "JOIN users u ON o.user_id = u.id " +
                     "WHERE o.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapRow(rs);
                    order.setItems(findItemsByOrderId(order.getId()));
                    return order;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding order by id: " + id, e);
        }
        return null;
    }

    public Order findByOrderNumber(String orderNumber) {
        String sql = "SELECT o.*, u.name AS user_name, u.email AS user_email " +
                     "FROM orders o " +
                     "JOIN users u ON o.user_id = u.id " +
                     "WHERE o.order_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapRow(rs);
                    order.setItems(findItemsByOrderId(order.getId()));
                    return order;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding order by number: " + orderNumber, e);
        }
        return null;
    }

    public List<Order> findByUserId(Long userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.name AS user_name, u.email AS user_email " +
                     "FROM orders o " +
                     "JOIN users u ON o.user_id = u.id " +
                     "WHERE o.user_id = ? ORDER BY o.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setItems(findItemsByOrderId(o.getId()));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding orders for user: " + userId, e);
        }
        return list;
    }

    public List<Order> findAllForAdmin() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.name AS user_name, u.email AS user_email " +
                     "FROM orders o " +
                     "JOIN users u ON o.user_id = u.id " +
                     "ORDER BY o.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = mapRow(rs);
                o.setItems(findItemsByOrderId(o.getId()));
                list.add(o);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all orders for admin", e);
        }
        return list;
    }

    /**
     * Executes the complete checkout in an atomic transaction:
     * 1. Checks and locks product inventory
     * 2. Decrements product stock
     * 3. Inserts order record
     * 4. Inserts order item records
     * 5. Inserts payment record
     * 6. Updates coupon usage count if coupon applied
     * 7. Clears user cart
     * Rolls back completely if any step fails.
     */
    public boolean placeOrderTransaction(Order order, List<OrderItem> items, Payment payment, Long cartIdToClear) {
        String insertOrderSql = "INSERT INTO orders (order_number, user_id, recipient_name, recipient_phone, " +
                "shipping_address, subtotal, discount_amount, shipping_fee, total_amount, order_status, " +
                "payment_status, payment_method, coupon_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String insertItemSql = "INSERT INTO order_items (order_id, product_id, product_name, unit_price, " +
                "discount_applied, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?)";

        String checkAndLockStockSql = "SELECT stock FROM products WHERE id = ? FOR UPDATE";
        String decrementStockSql = "UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?";

        String insertPaymentSql = "INSERT INTO payments (order_id, amount, method, status, transaction_ref) VALUES (?, ?, ?, ?, ?)";
        String updateCouponSql = "UPDATE coupons SET times_used = times_used + 1 WHERE code = ?";
        String clearCartSql = "DELETE FROM cart_items WHERE cart_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Verify and decrement stock for every item
            try (PreparedStatement checkPs = conn.prepareStatement(checkAndLockStockSql);
                 PreparedStatement decPs = conn.prepareStatement(decrementStockSql)) {
                
                for (OrderItem item : items) {
                    checkPs.setLong(1, item.getProductId());
                    try (ResultSet rs = checkPs.executeQuery()) {
                        if (!rs.next() || rs.getInt("stock") < item.getQuantity()) {
                            LOGGER.warning("Insufficient stock for product id: " + item.getProductId() + ". Aborting order.");
                            conn.rollback();
                            return false;
                        }
                    }

                    decPs.setInt(1, item.getQuantity());
                    decPs.setLong(2, item.getProductId());
                    decPs.setInt(3, item.getQuantity());
                    int updated = decPs.executeUpdate();
                    if (updated <= 0) {
                        LOGGER.warning("Failed to decrement stock for product id: " + item.getProductId());
                        conn.rollback();
                        return false;
                    }
                }
            }

            // 2. Insert Order
            long orderId;
            try (PreparedStatement orderPs = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                orderPs.setString(1, order.getOrderNumber());
                orderPs.setLong(2, order.getUserId());
                orderPs.setString(3, order.getRecipientName());
                orderPs.setString(4, order.getRecipientPhone());
                orderPs.setString(5, order.getShippingAddress());
                orderPs.setBigDecimal(6, order.getSubtotal());
                orderPs.setBigDecimal(7, order.getDiscountAmount());
                orderPs.setBigDecimal(8, order.getShippingFee());
                orderPs.setBigDecimal(9, order.getTotalAmount());
                orderPs.setString(10, order.getOrderStatus().name());
                orderPs.setString(11, order.getPaymentStatus().name());
                orderPs.setString(12, order.getPaymentMethod());
                orderPs.setString(13, order.getCouponCode());

                int affected = orderPs.executeUpdate();
                if (affected <= 0) {
                    conn.rollback();
                    return false;
                }
                try (ResultSet keys = orderPs.getGeneratedKeys()) {
                    if (keys.next()) {
                        orderId = keys.getLong(1);
                        order.setId(orderId);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            // 3. Insert Order Items
            try (PreparedStatement itemPs = conn.prepareStatement(insertItemSql)) {
                for (OrderItem item : items) {
                    itemPs.setLong(1, orderId);
                    itemPs.setLong(2, item.getProductId());
                    itemPs.setString(3, item.getProductName());
                    itemPs.setBigDecimal(4, item.getUnitPrice());
                    itemPs.setBigDecimal(5, item.getDiscountApplied());
                    itemPs.setInt(6, item.getQuantity());
                    itemPs.setBigDecimal(7, item.getSubtotal());
                    itemPs.addBatch();
                }
                itemPs.executeBatch();
            }

            // 4. Insert Payment record
            if (payment != null) {
                try (PreparedStatement payPs = conn.prepareStatement(insertPaymentSql)) {
                    payPs.setLong(1, orderId);
                    payPs.setBigDecimal(2, payment.getAmount());
                    payPs.setString(3, payment.getMethod());
                    payPs.setString(4, payment.getStatus().name());
                    payPs.setString(5, payment.getTransactionRef());
                    payPs.executeUpdate();
                }
            }

            // 5. Update coupon usage if applicable
            if (order.getCouponCode() != null && !order.getCouponCode().trim().isEmpty()) {
                try (PreparedStatement coupPs = conn.prepareStatement(updateCouponSql)) {
                    coupPs.setString(1, order.getCouponCode().trim().toUpperCase());
                    coupPs.executeUpdate();
                }
            }

            // 6. Clear user cart if cartId provided
            if (cartIdToClear != null && cartIdToClear > 0) {
                try (PreparedStatement clearPs = conn.prepareStatement(clearCartSql)) {
                    clearPs.setLong(1, cartIdToClear);
                    clearPs.executeUpdate();
                }
            }

            conn.commit(); // Transaction Successful
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction failed for placing order. Rolling back.", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error during transaction rollback", ex);
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    public boolean updateOrderStatus(Long orderId, Order.OrderStatus status) {
        String sql = "UPDATE orders SET order_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setLong(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating order status: " + orderId, e);
        }
        return false;
    }

    public boolean updatePaymentStatus(Long orderId, Order.PaymentStatus status) {
        String sql = "UPDATE orders SET payment_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setLong(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating payment status: " + orderId, e);
        }
        return false;
    }

    public List<OrderItem> findItemsByOrderId(Long orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, p.image_url FROM order_items oi " +
                     "LEFT JOIN products p ON oi.product_id = p.id " +
                     "WHERE oi.order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setId(rs.getLong("id"));
                    item.setOrderId(rs.getLong("order_id"));
                    item.setProductId(rs.getLong("product_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setProductImageUrl(rs.getString("image_url"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setDiscountApplied(rs.getBigDecimal("discount_applied"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setSubtotal(rs.getBigDecimal("subtotal"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching items for order: " + orderId, e);
        }
        return items;
    }

    public int countTotalOrders() {
        String sql = "SELECT COUNT(*) FROM orders";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total orders", e);
        }
        return 0;
    }

    public BigDecimal calculateTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status != 'CANCELLED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating total revenue", e);
        }
        return BigDecimal.ZERO;
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getLong("id"));
        o.setOrderNumber(rs.getString("order_number"));
        o.setUserId(rs.getLong("user_id"));
        try {
            o.setUserName(rs.getString("user_name"));
            o.setUserEmail(rs.getString("user_email"));
        } catch (SQLException ignored) {
        }
        o.setRecipientName(rs.getString("recipient_name"));
        o.setRecipientPhone(rs.getString("recipient_phone"));
        o.setShippingAddress(rs.getString("shipping_address"));
        o.setSubtotal(rs.getBigDecimal("subtotal"));
        o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        o.setShippingFee(rs.getBigDecimal("shipping_fee"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setOrderStatus(Order.OrderStatus.valueOf(rs.getString("order_status")));
        o.setPaymentStatus(Order.PaymentStatus.valueOf(rs.getString("payment_status")));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setCouponCode(rs.getString("coupon_code"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        o.setUpdatedAt(rs.getTimestamp("updated_at"));
        return o;
    }
}
