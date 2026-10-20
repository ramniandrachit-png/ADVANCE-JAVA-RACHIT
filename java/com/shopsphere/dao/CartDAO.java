package com.shopsphere.dao;

import com.shopsphere.model.Cart;
import com.shopsphere.model.CartItem;
import com.shopsphere.model.Product;
import com.shopsphere.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CartDAO {

    private static final Logger LOGGER = Logger.getLogger(CartDAO.class.getName());

    public Cart getOrCreateCartForUser(Long userId) {
        String findSql = "SELECT id, user_id FROM carts WHERE user_id = ?";
        String insertSql = "INSERT INTO carts (user_id) VALUES (?)";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Cart cart = new Cart();
                        cart.setId(rs.getLong("id"));
                        cart.setUserId(rs.getLong("user_id"));
                        cart.setItems(getCartItems(cart.getId()));
                        return cart;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, userId);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        Cart cart = new Cart();
                        cart.setId(keys.getLong(1));
                        cart.setUserId(userId);
                        cart.setItems(new ArrayList<>());
                        return cart;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving or creating cart for user: " + userId, e);
        }
        return null;
    }

    public List<CartItem> getCartItems(Long cartId) {
        List<CartItem> items = new ArrayList<>();
        String sql = "SELECT ci.id AS item_id, ci.cart_id, ci.product_id, ci.quantity, " +
                     "p.id AS prod_id, p.category_id, p.name AS prod_name, p.brand, p.description, " +
                     "p.price, p.discount, p.stock, p.image_url, p.status " +
                     "FROM cart_items ci " +
                     "JOIN products p ON ci.product_id = p.id " +
                     "WHERE ci.cart_id = ? AND p.status = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setId(rs.getLong("item_id"));
                    item.setCartId(rs.getLong("cart_id"));
                    item.setProductId(rs.getLong("product_id"));
                    item.setQuantity(rs.getInt("quantity"));

                    Product p = new Product();
                    p.setId(rs.getLong("prod_id"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setName(rs.getString("prod_name"));
                    p.setBrand(rs.getString("brand"));
                    p.setDescription(rs.getString("description"));
                    p.setPrice(rs.getBigDecimal("price"));
                    p.setDiscount(rs.getBigDecimal("discount"));
                    p.setStock(rs.getInt("stock"));
                    p.setImageUrl(rs.getString("image_url"));
                    p.setStatus(Product.Status.valueOf(rs.getString("status")));

                    item.setProduct(p);
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching items for cart: " + cartId, e);
        }
        return items;
    }

    public void addItem(Long cartId, Long productId, int quantity) {
        String upsertSql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?) " +
                           "ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(upsertSql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, productId);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding item to cart " + cartId, e);
        }
    }

    public void updateItemQuantity(Long cartId, Long productId, int quantity) {
        if (quantity <= 0) {
            removeItem(cartId, productId);
            return;
        }
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, cartId);
            ps.setLong(3, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating cart item quantity", e);
        }
    }

    public void removeItem(Long cartId, Long productId) {
        String sql = "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error removing item from cart", e);
        }
    }

    public void clearCart(Long cartId) {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error clearing cart: " + cartId, e);
        }
    }
}
