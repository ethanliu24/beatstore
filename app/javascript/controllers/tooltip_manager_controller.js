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

    // if start with tooltip hidden the dimensions would be all 0
    this.tooltipSize = this.containerTarget.getBoundingClientRect();
    this.hideTooltip();
    this.containerTarget.classList.remove("opacity-0");

    this.hoverHandler = this.showTooltip.bind(this);
    this.unhoverHandler = this.hideTooltip.bind(this);
    this.positionUpdateHandler = this.updateTooltipPosition.bind(this);

    this.anchor.addEventListener("mouseenter", this.hoverHandler);
    this.anchor.addEventListener("mouseleave", this.unhoverHandler);
    window.addEventListener("resize", this.positionUpdateHandler);
    this.updateTooltipPosition();
  }

  disconnect() {
    if (!this.anchor) return;

    this.anchor.removeEventListener("mouseenter", this.showTooltip.bind(this));
    this.anchor.removeEventListener("mouseleave", this.hideTooltip.bind(this));
    window.removeEventListener("resize", this.positionUpdateHandler);
  }

  showTooltip() {
    this.containerTarget.classList.remove("hidden");
  }

  hideTooltip() {
    this.containerTarget.classList.add("hidden");
  }

  updateTooltipPosition() {
    const tooltip = this.containerTarget;
    const anchorRect = this.anchor.getBoundingClientRect();
    const tooltipRect = this.tooltipSize;

    const x = anchorRect.left + (anchorRect.width / 2) - (tooltipRect.width / 2);
    const y = anchorRect.top - tooltipRect.height - 8;

    tooltip.style.left = `${Math.round(x)}px`;
    tooltip.style.top = `${Math.round(y)}px`;
  }
}
