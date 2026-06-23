import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = [ "summary", "body", "expandIcon" ];

  connect() {
  }

  toggleExpand() {
    if (this.isActive()) {
      this.extract();
    } else {
      this.expand();
    }
  }

  expand() {
    this.summaryTarget.classList.add("active");
    this.bodyTarget.style.maxHeight = this.bodyTarget.scrollHeight + "px";
    this.expandIconTarget.style.transform = "rotate(90deg)";
  }

  extract() {
    this.summaryTarget.classList.remove("active");
    this.bodyTarget.style.maxHeight = null;
    this.expandIconTarget.style.transform = "rotate(0deg)";
  }

  isActive() {
    return this.bodyTarget.style.maxHeight;
  }
}
