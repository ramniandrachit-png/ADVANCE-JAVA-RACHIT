package com.shopsphere.service;

import com.shopsphere.dao.CouponDAO;
import com.shopsphere.model.Coupon;

import java.math.BigDecimal;
import java.util.List;

public class CouponService {

    private final CouponDAO couponDAO;

    public CouponService() {
        this.couponDAO = new CouponDAO();
    }

    public CouponService(CouponDAO couponDAO) {
        this.couponDAO = couponDAO;
    }

    public Coupon getCouponByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        return couponDAO.findByCode(code.trim().toUpperCase());
    }

    public Coupon validateCoupon(String code, BigDecimal cartSubtotal) {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Coupon code cannot be empty.");
        }
        Coupon coupon = couponDAO.findByCode(code.trim().toUpperCase());
        if (coupon == null) {
            throw new IllegalArgumentException("Invalid coupon code. Please check and try again.");
        }
        if (!coupon.isValid()) {
            throw new IllegalArgumentException("This coupon has expired or reached its maximum usage limit.");
        }
        if (cartSubtotal != null && coupon.getMinOrderAmount() != null 
                && cartSubtotal.compareTo(coupon.getMinOrderAmount()) < 0) {
            throw new IllegalArgumentException(String.format("Coupon requires a minimum order amount of $%.2f.", coupon.getMinOrderAmount()));
        }
        return coupon;
    }

    public List<Coupon> getAllCoupons() {
        return couponDAO.findAll();
    }

    public boolean createCoupon(Coupon coupon) {
        if (coupon.getCode() == null || coupon.getCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Coupon code is required.");
        }
        if (coupon.getDiscountValue() == null || coupon.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Discount value must be greater than zero.");
        }
        if (coupon.getExpiryDate() == null) {
            throw new IllegalArgumentException("Expiry date is required.");
        }
        return couponDAO.create(coupon);
    }

    public boolean updateCoupon(Coupon coupon) {
        if (coupon.getId() == null || coupon.getId() <= 0) {
            throw new IllegalArgumentException("Valid coupon ID is required.");
        }
        return couponDAO.update(coupon);
    }

    public boolean deleteCoupon(Integer id) {
        if (id == null || id <= 0) return false;
        return couponDAO.delete(id);
    }

    public boolean toggleCouponStatus(Integer id) {
        Coupon c = couponDAO.findById(id);
        if (c == null) return false;
        Coupon.Status next = (c.getStatus() == Coupon.Status.ACTIVE) ? Coupon.Status.DISABLED : Coupon.Status.ACTIVE;
        return couponDAO.updateStatus(id, next);
    }
}
