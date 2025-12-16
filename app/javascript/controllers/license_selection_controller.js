import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="license-selection"
export default class extends Controller {
  static values = {
    trackPreviewModalUrl: String,
  };

  connect() {
    this.selectedId = null;
  }

  selectLicense(e) {
    this.selectedId = parseInt(e.currentTarget.dataset.licenseId);
  }

  fetchPurchaseModal() {
    const url = new URL(this.trackPreviewModalUrlValue);
    if (this.selectedId) url.searchParams.set("initial_id", this.selectedId);

    fetch(url.toString(), {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
