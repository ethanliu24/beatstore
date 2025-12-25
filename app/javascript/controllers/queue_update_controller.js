import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="queue-update"
export default class extends Controller {
  static values = {
    queueScope: String
  };

  connect() {
    document.dispatchEvent(new CustomEvent("update-queue", {
      detail: {
        queueScope: this.queueScopeValue
      }
    }));

    this.element.remove();
  }
}
