package com.shopsphere.controller;

import com.shopsphere.model.Coupon;
import com.shopsphere.service.CouponService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AdminCouponServlet", urlPatterns = {"/admin/coupons"})
public class AdminCouponServlet extends HttpServlet {

    private CouponService couponService;

    @Override
    public void init() throws ServletException {
        this.couponService = new CouponService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Coupon> coupons = couponService.getAllCoupons();
        request.setAttribute("coupons", coupons);

        request.getRequestDispatcher("/admin/coupons.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create": {
                    Coupon c = new Coupon();
                    c.setCode(request.getParameter("code"));
                    c.setDiscountType(Coupon.DiscountType.valueOf(request.getParameter("discountType")));
                    c.setDiscountValue(new BigDecimal(request.getParameter("discountValue")));
                    c.setMinOrderAmount(new BigDecimal(request.getParameter("minOrderAmount")));
                    c.setUsageLimit(Integer.parseInt(request.getParameter("usageLimit")));
                    c.setExpiryDate(Date.valueOf(request.getParameter("expiryDate")));
                    c.setStatus(Coupon.Status.valueOf(request.getParameter("status")));

                    couponService.createCoupon(c);
                    session.setAttribute("flashSuccess", "Coupon '" + c.getCode() + "' created.");
                    break;
                }
                case "toggleStatus": {
                    Integer id = Integer.parseInt(request.getParameter("id"));
                    couponService.toggleCouponStatus(id);
                    session.setAttribute("flashSuccess", "Coupon status updated.");
                    break;
                }
                case "delete": {
                    Integer id = Integer.parseInt(request.getParameter("id"));
                    couponService.deleteCoupon(id);
                    session.setAttribute("flashSuccess", "Coupon deleted.");
                    break;
                }
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("flashError", "Coupon operation failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/coupons");
    }
}
