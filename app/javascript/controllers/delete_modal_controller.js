import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delete-modal"
export default class extends Controller {
  static values = {
    deleteApiUrl: String,
    redirectUrl: String,
  }

  connect() {
  }

  delete_redirect() {
    this.send_request(true);
  }

  delete_no_redirect() {
    this.send_request(false);
  }

  send_request(redirect = false) {
    fetch(this.deleteApiUrlValue, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    }).then(() => {
      if (redirect) {
        window.location.replace(this.redirectUrlValue || "/");
      }
    });
    // TODO show toast on success/failure?
  }
}
