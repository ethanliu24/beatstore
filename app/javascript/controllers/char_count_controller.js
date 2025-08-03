import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="char-count"
export default class extends Controller {
  static targets = ["input", "count"];

  connect() {
    this.count();  // initialize count on connect
  }

  count() {
    this.countTarget.textContent = this.inputTarget.value.length;
  }
}
