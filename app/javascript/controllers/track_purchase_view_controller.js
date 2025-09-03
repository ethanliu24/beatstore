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

  addToCart() {
    if (!this.selectedLicenseIdValue) return;

    fetch(this.createCartItemUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: {
        product_id: this.trackIdValue,
        product_type: this.productTypeValue,
        license_id: this.selectedLicenseId,
        quantity: this.quantity
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
