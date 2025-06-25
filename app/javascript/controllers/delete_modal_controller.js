import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delete-modal"
export default class extends Controller {
  static values = {
    deleteApiUrl: String
  }

  connect() {
  }

  delete() {
    fetch(this.deleteApiUrlValue, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    }).then(() => window.location = "");
    // TODO show toast?
  }
}
