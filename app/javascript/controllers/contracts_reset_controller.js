import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="contracts-reset"
export default class extends Controller {
  static targets = [ "documentContainer" ];
  static values = {
    url: String
  }

  connect() {
  }

  reset() {
    if (window.confirm("Reset contract? This action will not update the database, just frontend.")) {
      fetch(this.urlValue, {
        method: "GET",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Content-Type": "application/json"
        }
      })
        .then(res => res.json())
        .then(json => json.template)
        .then(template => this.documentContainerTarget.value = template)
    }
  }
}
