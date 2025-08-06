import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect () {
    setTimeout(() => this.dismiss(), 3000);
  }

  dismiss () {
    this.element.classList.add("fade-out");
    setTimeout(() => this.element.remove(), 200);
  }
}
