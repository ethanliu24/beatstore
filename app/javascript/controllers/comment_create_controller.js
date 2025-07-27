import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-create"
export default class extends Controller {
  static targets = ["form"];

  connect() {
  }

  submitForm() {
    this.resetForm();
    Turbo.visit(window.location.href, { action: "replace" })
    document.addEventListener("turbo:load", () => {
      const el = document.getElementById("comments");
      if (el) el.scrollIntoView({ behavior: "smooth" });
    }, { once: true });
  }

  resetForm() {
    this.formTarget.reset();
  }
}
