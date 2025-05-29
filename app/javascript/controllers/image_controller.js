import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image"
export default class extends Controller {
  static targets = ["upload", "cover", "placeholder"];

  connect() {
  }

  onchange() {
    this.coverTarget.src = URL.createObjectURL(this.uploadTarget.files[0]);
    this.coverTarget.classList.remove("hidden");
    this.placeholderTarget.classList.add("hidden");
  }
}
