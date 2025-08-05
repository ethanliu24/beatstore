import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal-manager"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
  }

  close() {
    this.element.remove();
  }

  stopPropagation(e) {
    e.stopPropagation();
  }
}
