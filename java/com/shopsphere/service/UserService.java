package com.shopsphere.service;

import com.shopsphere.dao.UserDAO;
import com.shopsphere.model.User;
import com.shopsphere.util.PasswordUtil;

import java.util.List;
import java.util.regex.Pattern;

public class UserService {

    private final UserDAO userDAO;

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[+0-9\\s-]{7,20}$");

    public UserService() {
        this.userDAO = new UserDAO();
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Registers a new customer with full server-side validation.
     */
    public User registerCustomer(String name, String email, String phone, String password) {
        if (name == null || name.trim().length() < 2) {
            throw new IllegalArgumentException("Full name must be at least 2 characters long.");
        }
        if (email == null || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            throw new IllegalArgumentException("Please provide a valid email address.");
        }
        if (phone != null && !phone.trim().isEmpty() && !PHONE_PATTERN.matcher(phone.trim()).matches()) {
            throw new IllegalArgumentException("Please provide a valid phone number.");
        }
        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters long.");
        }

        String normalizedEmail = email.trim().toLowerCase();
        if (userDAO.emailExists(normalizedEmail)) {
            throw new IllegalArgumentException("An account with this email address already exists.");
        }

        String passwordHash = PasswordUtil.hashPassword(password);
        User user = new User();
        user.setName(name.trim());
        user.setEmail(normalizedEmail);
        user.setPhone(phone != null ? phone.trim() : null);
        user.setPasswordHash(passwordHash);
        user.setRole(User.Role.CUSTOMER);
        user.setStatus(User.Status.ACTIVE);

        boolean created = userDAO.create(user);
        if (created) {
            return user;
        }
        throw new IllegalStateException("Failed to register user due to a database error.");
    }

    /**
     * Authenticates a user credentials.
     */
    public User authenticate(String email, String plainPassword) {
        if (email == null || plainPassword == null || email.trim().isEmpty() || plainPassword.isEmpty()) {
            return null;
        }

        User user = userDAO.findByEmail(email.trim().toLowerCase());
        if (user == null) {
            return null; // User not found
        }

        if (user.getStatus() != User.Status.ACTIVE) {
            throw new IllegalStateException("Your account has been suspended. Please contact support.");
        }

        boolean match = PasswordUtil.checkPassword(plainPassword, user.getPasswordHash());
        if (match) {
            return user;
        }
        return null;
    }

    public User getUserById(Long userId) {
        return userDAO.findById(userId);
    }

    public boolean updateProfile(Long userId, String name, String phone) {
        if (name == null || name.trim().length() < 2) {
            throw new IllegalArgumentException("Name must be at least 2 characters long.");
        }
        User user = userDAO.findById(userId);
        if (user == null) {
            return false;
        }
        user.setName(name.trim());
        user.setPhone(phone != null ? phone.trim() : null);
        return userDAO.updateProfile(user);
    }

    public boolean changePassword(Long userId, String currentPassword, String newPassword) {
        User user = userDAO.findById(userId);
        if (user == null) {
            return false;
        }
        if (!PasswordUtil.checkPassword(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("The current password entered is incorrect.");
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new IllegalArgumentException("New password must be at least 6 characters long.");
        }
        String newHash = PasswordUtil.hashPassword(newPassword);
        return userDAO.updatePassword(userId, newHash);
    }

    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    public boolean toggleUserStatus(Long userId) {
        User user = userDAO.findById(userId);
        if (user == null) return false;
        User.Status newStatus = (user.getStatus() == User.Status.ACTIVE) ? User.Status.SUSPENDED : User.Status.ACTIVE;
        return userDAO.updateStatus(userId, newStatus);
    }

    public int countCustomers() {
        return userDAO.countTotalUsers();
    }
}
