package com.shopsphere.service;

import com.shopsphere.dao.AddressDAO;
import com.shopsphere.model.Address;

import java.util.List;

public class AddressService {

    private final AddressDAO addressDAO;

    public AddressService() {
        this.addressDAO = new AddressDAO();
    }

    public AddressService(AddressDAO addressDAO) {
        this.addressDAO = addressDAO;
    }

    public List<Address> getUserAddresses(Long userId) {
        if (userId == null || userId <= 0) return List.of();
        return addressDAO.findByUserId(userId);
    }

    public Address getAddressById(Long id) {
        if (id == null || id <= 0) return null;
        return addressDAO.findById(id);
    }

    public boolean addAddress(Address address) {
        validateAddress(address);
        return addressDAO.create(address);
    }

    public boolean updateAddress(Address address) {
        if (address.getId() == null || address.getId() <= 0) {
            throw new IllegalArgumentException("Address ID is required for update.");
        }
        validateAddress(address);
        return addressDAO.update(address);
    }

    public boolean setDefaultAddress(Long userId, Long addressId) {
        if (userId == null || addressId == null) return false;
        return addressDAO.setDefault(userId, addressId);
    }

    public boolean deleteAddress(Long addressId, Long userId) {
        if (addressId == null || userId == null) return false;
        return addressDAO.delete(addressId, userId);
    }

    private void validateAddress(Address a) {
        if (a.getRecipientName() == null || a.getRecipientName().trim().isEmpty()) {
            throw new IllegalArgumentException("Recipient name is required.");
        }
        if (a.getPhone() == null || a.getPhone().trim().isEmpty()) {
            throw new IllegalArgumentException("Contact phone number is required.");
        }
        if (a.getAddressLine1() == null || a.getAddressLine1().trim().isEmpty()) {
            throw new IllegalArgumentException("Address line 1 is required.");
        }
        if (a.getCity() == null || a.getCity().trim().isEmpty()) {
            throw new IllegalArgumentException("City is required.");
        }
        if (a.getState() == null || a.getState().trim().isEmpty()) {
            throw new IllegalArgumentException("State is required.");
        }
        if (a.getPostalCode() == null || a.getPostalCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Postal code / PIN code is required.");
        }
    }
}
