package com.shopsphere.service;

import com.shopsphere.model.Coupon;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

class CouponServiceTest {

    @Test
    @DisplayName("Coupon validity should evaluate active date and limits correctly")
    void testCouponValidity() {
        Coupon coupon = new Coupon();
        coupon.setCode("TEST20");
        coupon.setDiscountType(Coupon.DiscountType.PERCENTAGE);
        coupon.setDiscountValue(new BigDecimal("20.00"));
        coupon.setMinOrderAmount(new BigDecimal("50.00"));
        coupon.setUsageLimit(10);
        coupon.setTimesUsed(2);
        coupon.setExpiryDate(Date.valueOf(LocalDate.now().plusDays(30)));
        coupon.setStatus(Coupon.Status.ACTIVE);

        assertTrue(coupon.isValid(), "Coupon with future date and active status must be valid");

        // Expired date
        coupon.setExpiryDate(Date.valueOf(LocalDate.now().minusDays(1)));
        assertFalse(coupon.isValid(), "Coupon with past date must be invalid");

        // Limit reached
        coupon.setExpiryDate(Date.valueOf(LocalDate.now().plusDays(30)));
        coupon.setTimesUsed(10);
        assertFalse(coupon.isValid(), "Coupon reaching its limit must be invalid");
    }
}
