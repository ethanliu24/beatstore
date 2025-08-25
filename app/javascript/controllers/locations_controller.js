import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="locations"
export default class extends Controller {
  connect() {
  }

  provincesForCountry(e) {
    const country = e.target.selectedOptions[0].value

    fetch(`/location/provinces?country=${country}`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
