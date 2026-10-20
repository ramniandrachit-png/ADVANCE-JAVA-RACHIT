package com.shopsphere.dao;

import com.shopsphere.model.Coupon;
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

public class CouponDAO {

    private static final Logger LOGGER = Logger.getLogger(CouponDAO.class.getName());

    public Coupon findById(Integer id) {
        String sql = "SELECT * FROM coupons WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding coupon by id: " + id, e);
        }
        return null;
    }

    public Coupon findByCode(String code) {
        if (code == null) return null;
        String sql = "SELECT * FROM coupons WHERE code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding coupon by code: " + code, e);
        }
        return null;
    }

    public List<Coupon> findAll() {
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT * FROM coupons ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all coupons", e);
        }
        return list;
    }

    public boolean create(Coupon c) {
        String sql = "INSERT INTO coupons (code, discount_type, discount_value, min_order_amount, usage_limit, times_used, expiry_date, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, c.getCode());
            ps.setString(2, c.getDiscountType().name());
            ps.setBigDecimal(3, c.getDiscountValue());
            ps.setBigDecimal(4, c.getMinOrderAmount());
            ps.setInt(5, c.getUsageLimit());
            ps.setInt(6, c.getTimesUsed());
            ps.setDate(7, c.getExpiryDate());
            ps.setString(8, c.getStatus() != null ? c.getStatus().name() : Coupon.Status.ACTIVE.name());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        c.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating coupon: " + c.getCode(), e);
        }
        return false;
    }

    public boolean update(Coupon c) {
        String sql = "UPDATE coupons SET discount_type = ?, discount_value = ?, min_order_amount = ?, " +
                     "usage_limit = ?, expiry_date = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getDiscountType().name());
            ps.setBigDecimal(2, c.getDiscountValue());
            ps.setBigDecimal(3, c.getMinOrderAmount());
            ps.setInt(4, c.getUsageLimit());
            ps.setDate(5, c.getExpiryDate());
            ps.setString(6, c.getStatus().name());
            ps.setInt(7, c.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating coupon: " + c.getId(), e);
        }
        return false;
    }

    public boolean updateStatus(Integer id, Coupon.Status status) {
        String sql = "UPDATE coupons SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.name());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating coupon status: " + id, e);
        }
        return false;
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM coupons WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting coupon: " + id, e);
        }
        return false;
    }

    private Coupon mapRow(ResultSet rs) throws SQLException {
        Coupon c = new Coupon();
        c.setId(rs.getInt("id"));
        c.setCode(rs.getString("code"));
        c.setDiscountType(Coupon.DiscountType.valueOf(rs.getString("discount_type")));
        c.setDiscountValue(rs.getBigDecimal("discount_value"));
        c.setMinOrderAmount(rs.getBigDecimal("min_order_amount"));
        c.setUsageLimit(rs.getInt("usage_limit"));
        c.setTimesUsed(rs.getInt("times_used"));
        c.setExpiryDate(rs.getDate("expiry_date"));
        c.setStatus(Coupon.Status.valueOf(rs.getString("status")));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
