import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = [ "summary", "body", "expandIcon" ];
  static values = {
    expandInitially: Boolean
  }

  connect() {
    this.isActive = this.expandInitiallyValue ?? false;
    if (this.isActive) {
      this.expand();
    }
  }

  toggleExpand() {
    if (this.isActive) {
      this.extract();
    } else {
      this.expand();
    }
  }

  expand() {
    this.isActive = true;
    this.summaryTarget.classList.add("active");
    this.bodyTarget.style.maxHeight = this.bodyTarget.scrollHeight + "px";
    this.expandIconTarget.style.transform = "rotate(90deg)";
  }

  extract() {
    this.isActive = false;
    this.summaryTarget.classList.remove("active");
    this.bodyTarget.style.maxHeight = "0px";
    this.expandIconTarget.style.transform = "rotate(0deg)";
  }
}
