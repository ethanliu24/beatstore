import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-create"
export default class extends Controller {
  static targets = ["form", "charCount"];

  connect() {
  }

  reset() {
    this.formTarget.reset();
    this.charCountTarget.innerText = "0";
  }
}
