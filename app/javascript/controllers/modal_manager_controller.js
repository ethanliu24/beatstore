import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal-manager"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    document.body.classList.add("overflow-hidden");
    this.element.addEventListener("turbo:submit-end", () => {
      this.close();
    });
  }

  close() {
    document.body.classList.remove("overflow-hidden");
    this.element.remove();
  }

  stopPropagation(e) {
    e.stopPropagation();
  }
}
