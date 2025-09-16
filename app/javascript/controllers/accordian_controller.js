import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="accordian"
export default class extends Controller {
  static targets = [ "summary", "body", "expandIcon" ];

  connect() {
  }

  toggleExpand() {
    this.summaryTarget.classList.toggle("active");

    if (this.bodyTarget.style.maxHeight) {
      this.bodyTarget.style.maxHeight = null;
      this.expandIconTarget.style.transform = "rotate(0deg)";
    } else {
      this.bodyTarget.style.maxHeight = this.bodyTarget.scrollHeight + "px";
      this.expandIconTarget.style.transform = "rotate(90deg)";
    }
  }
}
