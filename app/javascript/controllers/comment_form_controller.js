import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-form"
export default class extends Controller {
  static targets = ["form"];

  connect() {
  }

  submitForm() {
    this.resetForm();
    Turbo.visit(window.location.href, { action: "replace" });
  }

  resetForm() {
    this.formTarget.reset();
  }
}
