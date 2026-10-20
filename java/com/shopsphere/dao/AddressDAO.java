package com.shopsphere.dao;

import com.shopsphere.model.Address;
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

public class AddressDAO {

    private static final Logger LOGGER = Logger.getLogger(AddressDAO.class.getName());

    public Address findById(Long id) {
        String sql = "SELECT * FROM addresses WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding address by id: " + id, e);
        }
        return null;
    }

    public List<Address> findByUserId(Long userId) {
        List<Address> list = new ArrayList<>();
        String sql = "SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding addresses for user: " + userId, e);
        }
        return list;
    }

    public Address findDefaultByUserId(Long userId) {
        String sql = "SELECT * FROM addresses WHERE user_id = ? AND is_default = TRUE LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding default address for user: " + userId, e);
        }
        return null;
    }

    public boolean create(Address a) {
        String sql = "INSERT INTO addresses (user_id, recipient_name, phone, address_line1, address_line2, city, state, postal_code, country, is_default) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            if (a.isDefault()) {
                clearDefault(conn, a.getUserId());
            }

            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, a.getUserId());
                ps.setString(2, a.getRecipientName());
                ps.setString(3, a.getPhone());
                ps.setString(4, a.getAddressLine1());
                ps.setString(5, a.getAddressLine2());
                ps.setString(6, a.getCity());
                ps.setString(7, a.getState());
                ps.setString(8, a.getPostalCode());
                ps.setString(9, a.getCountry() != null ? a.getCountry() : "India");
                ps.setBoolean(10, a.isDefault());

                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            a.setId(keys.getLong(1));
                        }
                    }
                    return true;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating address for user: " + a.getUserId(), e);
        }
        return false;
    }

    public boolean update(Address a) {
        String sql = "UPDATE addresses SET recipient_name = ?, phone = ?, address_line1 = ?, address_line2 = ?, " +
                     "city = ?, state = ?, postal_code = ?, country = ?, is_default = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            if (a.isDefault()) {
                clearDefault(conn, a.getUserId());
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, a.getRecipientName());
                ps.setString(2, a.getPhone());
                ps.setString(3, a.getAddressLine1());
                ps.setString(4, a.getAddressLine2());
                ps.setString(5, a.getCity());
                ps.setString(6, a.getState());
                ps.setString(7, a.getPostalCode());
                ps.setString(8, a.getCountry());
                ps.setBoolean(9, a.isDefault());
                ps.setLong(10, a.getId());
                ps.setLong(11, a.getUserId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating address: " + a.getId(), e);
        }
        return false;
    }

    public boolean setDefault(Long userId, Long addressId) {
        try (Connection conn = DBConnection.getConnection()) {
            clearDefault(conn, userId);
            String sql = "UPDATE addresses SET is_default = TRUE WHERE id = ? AND user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, addressId);
                ps.setLong(2, userId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error setting default address: " + addressId, e);
        }
        return false;
    }

    public boolean delete(Long addressId, Long userId) {
        String sql = "DELETE FROM addresses WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting address: " + addressId, e);
        }
        return false;
    }

    private void clearDefault(Connection conn, Long userId) throws SQLException {
        String sql = "UPDATE addresses SET is_default = FALSE WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.executeUpdate();
        }
    }

    private Address mapRow(ResultSet rs) throws SQLException {
        Address a = new Address();
        a.setId(rs.getLong("id"));
        a.setUserId(rs.getLong("user_id"));
        a.setRecipientName(rs.getString("recipient_name"));
        a.setPhone(rs.getString("phone"));
        a.setAddressLine1(rs.getString("address_line1"));
        a.setAddressLine2(rs.getString("address_line2"));
        a.setCity(rs.getString("city"));
        a.setState(rs.getString("state"));
        a.setPostalCode(rs.getString("postal_code"));
        a.setCountry(rs.getString("country"));
        a.setDefault(rs.getBoolean("is_default"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        return a;
    }
}
