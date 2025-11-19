import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-purchase-view"
export default class extends Controller {
  static values = {
    createCartItemUrl: String,
    initialLicenseId: Number,
    trackId: Number,
    productType: String
  }

  connect() {
    this.selectedLicenseId = this.initialLicenseIdValue;
    this.quantity = 1;
  }

  selectLicense(e) {
    this.selectedLicenseId = e.currentTarget.dataset.licenseId;
  }

  addToCart(e) {
    if (!this.selectedLicenseId) return;

    const cartItemBody = {
      product_id: this.trackIdValue,
      product_type: this.productTypeValue,
      license_id: this.selectedLicenseId,
      quantity: this.quantity
    }

    // Should redirect in the backend. The controller expects turbo stream so need to find a workaround
    if (e.currentTarget.hasAttribute("data-purchase")) Turbo.visit("/cart");

    fetch(`${this.createCartItemUrlValue}?${params.toString()}`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
        // "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({
        cart_item: cartItemBody
      })
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
