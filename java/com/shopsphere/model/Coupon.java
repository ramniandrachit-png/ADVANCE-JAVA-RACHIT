package com.shopsphere.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;

public class Coupon implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum DiscountType {
        PERCENTAGE, FIXED
    }

    public enum Status {
        ACTIVE, EXPIRED, DISABLED
    }

    private Integer id;
    private String code;
    private DiscountType discountType;
    private BigDecimal discountValue;
    private BigDecimal minOrderAmount;
    private Integer usageLimit;
    private Integer timesUsed;
    private Date expiryDate;
    private Status status;
    private Timestamp createdAt;

    public Coupon() {
        this.discountType = DiscountType.PERCENTAGE;
        this.minOrderAmount = BigDecimal.ZERO;
        this.usageLimit = 100;
        this.timesUsed = 0;
        this.status = Status.ACTIVE;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code != null ? code.trim().toUpperCase() : null;
    }

    public DiscountType getDiscountType() {
        return discountType;
    }

    public void setDiscountType(DiscountType discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMinOrderAmount() {
        return minOrderAmount != null ? minOrderAmount : BigDecimal.ZERO;
    }

    public void setMinOrderAmount(BigDecimal minOrderAmount) {
        this.minOrderAmount = minOrderAmount;
    }

    public Integer getUsageLimit() {
        return usageLimit != null ? usageLimit : 0;
    }

    public void setUsageLimit(Integer usageLimit) {
        this.usageLimit = usageLimit;
    }

    public Integer getTimesUsed() {
        return timesUsed != null ? timesUsed : 0;
    }

    public void setTimesUsed(Integer timesUsed) {
        this.timesUsed = timesUsed;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Checks if this coupon is active and has not expired.
     */
    public boolean isValid() {
        if (this.status != Status.ACTIVE) {
            return false;
        }
        if (usageLimit > 0 && timesUsed >= usageLimit) {
            return false;
        }
        if (expiryDate != null) {
            LocalDate today = LocalDate.now();
            if (expiryDate.toLocalDate().isBefore(today)) {
                return false;
            }
        }
        return true;
    }
}
