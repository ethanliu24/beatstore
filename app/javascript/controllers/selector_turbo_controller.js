import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="selector-turbo"
/**
 * This controller is for dynamically rendering different contents when a selector option changes
 * through turbo. For example, selecting different country will dynamically render the country's
 * corresponding provinces/states.
 */
export default class extends Controller {
  static values = {
    url: String,
    param: String,
  }

  connect() {
  }

  change(e) {
    const params = new URLSearchParams()
    params.append(this.paramValue, e.target.selectedOptions[0].value)

    fetch(`${this.urlValue}?${params}`, {
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
