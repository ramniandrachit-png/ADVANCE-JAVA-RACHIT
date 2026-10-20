/**
 * ShopSphere Core Client-side Scripts
 */

document.addEventListener("DOMContentLoaded", () => {
    // 1. Auto-dismiss alerts after 5 seconds
    const alerts = document.querySelectorAll(".alert");
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.style.transition = "opacity 0.5s ease, transform 0.5s ease";
            alert.style.opacity = "0";
            alert.style.transform = "translateY(-10px)";
            setTimeout(() => alert.remove(), 500);
        }, 5000);
    });

    // 2. Destructive action confirmation dialogs
    document.querySelectorAll("[data-confirm]").forEach(elem => {
        elem.addEventListener("click", (e) => {
            const message = elem.getAttribute("data-confirm") || "Are you sure you want to perform this action?";
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });

    // 3. Fallback for broken product images
    document.querySelectorAll("img").forEach(img => {
        img.addEventListener("error", () => {
            // High-resolution SVG placeholder fallback
            img.src = "data:image/svg+xml;charset=UTF-8,%3Csvg%20width%3D%22400%22%20height%3D%22400%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20400%20400%22%20preserveAspectRatio%3D%22none%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%23holder%20text%20%7B%20fill%3A%2394a3b8%3Bfont-weight%3Abold%3Bfont-family%3Asans-serif%3Bfont-size%3A20pt%20%7D%20%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%20id%3D%22holder%22%3E%3Crect%20width%3D%22400%22%20height%3D%22400%22%20fill%3D%22%23f1f5f9%22%3E%3C%2Frect%3E%3Cg%3E%3Ctext%20x%3D%22125%22%20y%3D%22208%22%3EShopSphere%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E";
        });
    });

    // 4. Quantity Picker Controller
    document.querySelectorAll(".quantity-picker").forEach(picker => {
        const input = picker.querySelector(".qty-input");
        const decBtn = picker.querySelector(".qty-dec");
        const incBtn = picker.querySelector(".qty-inc");
        const max = parseInt(input.getAttribute("max") || "999", 10);
        const min = parseInt(input.getAttribute("min") || "1", 10);

        if (decBtn && incBtn && input) {
            decBtn.addEventListener("click", () => {
                let val = parseInt(input.value || "1", 10);
                if (val > min) {
                    input.value = val - 1;
                    input.dispatchEvent(new Event("change"));
                }
            });
            incBtn.addEventListener("click", () => {
                let val = parseInt(input.value || "1", 10);
                if (val < max) {
                    input.value = val + 1;
                    input.dispatchEvent(new Event("change"));
                }
            });
        }
    });

    // 5. Checkout Address Selection Toggle
    const addressRadios = document.querySelectorAll("input[name='addressOption']");
    const newAddressForm = document.getElementById("newAddressFields");
    if (addressRadios.length && newAddressForm) {
        addressRadios.forEach(radio => {
            radio.addEventListener("change", () => {
                if (radio.value === "new") {
                    newAddressForm.style.display = "block";
                    newAddressForm.querySelectorAll("input").forEach(i => i.required = true);
                } else {
                    newAddressForm.style.display = "none";
                    newAddressForm.querySelectorAll("input").forEach(i => i.required = false);
                }
            });
        });
    }

    // 6. Registration password match checking
    const regPassword = document.getElementById("regPassword");
    const regConfirm = document.getElementById("regConfirm");
    const regMismatchHint = document.getElementById("regMismatchHint");
    if (regPassword && regConfirm && regMismatchHint) {
        function validatePasswordMatch() {
            if (regConfirm.value.length > 0 && regPassword.value !== regConfirm.value) {
                regMismatchHint.style.display = "block";
            } else {
                regMismatchHint.style.display = "none";
            }
        }
        regPassword.addEventListener("input", validatePasswordMatch);
        regConfirm.addEventListener("input", validatePasswordMatch);
    }
});

// Modal helpers
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add("active");
        document.body.style.overflow = "hidden";
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove("active");
        document.body.style.overflow = "";
    }
}
