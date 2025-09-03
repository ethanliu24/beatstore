import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-purchase-view"
export default class extends Controller {
  static values = {

  }

  connect() {
    this.selectedLicenseId = null;
  }

  selectLicense(e) {
    this.selectedLicenseId = e.currentTarget.dataset.licenseId;
  }

  addToCart() {

  }
}
