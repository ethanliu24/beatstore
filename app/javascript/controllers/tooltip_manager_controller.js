import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tooltip-manager"
export default class extends Controller {
  static targets = ["container"];
  static values = {
    anchorId: String
  };

  connect() {
    this.anchor = document.getElementById(this.anchorIdValue);

    if (!this.anchor) {
      console.error("Tooltip anchor missing. It should be a HTML id.");
      return;
    }

    this.anchor.addEventListener("mouseenter", this.showTooltip.bind(this));
    this.anchor.addEventListener("mouseleave", this.hideTooltip.bind(this));
  }

  disconnect() {
    this.anchor.removeEventListener("mouseenter", this.showTooltip.bind(this));
    this.anchor.removeEventListener("mouseleave", this.hideTooltip.bind(this));
  }

  showTooltip() {
    this.containerTarget.classList.remove("hidden");
  }

  hideTooltip() {
    this.containerTarget.classList.add("hidden");
  }
}
