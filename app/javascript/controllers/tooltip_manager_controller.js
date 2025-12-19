import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tooltip-manager"
export default class extends Controller {
  static targets = ["container"];
  static values = {
    anchorId: String,
    position: String
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
  }

  disconnect() {
    if (!this.anchor) return;

    this.anchor.removeEventListener("mouseenter", this.showTooltip.bind(this));
    this.anchor.removeEventListener("mouseleave", this.hideTooltip.bind(this));
    window.removeEventListener("resize", this.positionUpdateHandler);
  }

  showTooltip() {
    this.updateTooltipPosition();
    this.containerTarget.classList.remove("hidden");
  }

  hideTooltip() {
    this.updateTooltipPosition();
    this.containerTarget.classList.add("hidden");
  }

  updateTooltipPosition() {
    const tooltip = this.containerTarget;
    const anchorRect = this.anchor.getBoundingClientRect();
    const tooltipRect = this.tooltipSize;
    const offsetX = 16;
    const offsetY = 12;
    let x, y;

    switch (this.positionValue) {
      case "left":
        x = anchorRect.left - tooltipRect.width - offsetX;
        y = anchorRect.top + (anchorRect.height / 2) - (tooltipRect.height / 2);
        break;
      case "right":
        x = anchorRect.right + offsetX;
        y = anchorRect.top + (anchorRect.height / 2) - (tooltipRect.height / 2);
        break;
      case "bottom":
        x = anchorRect.left + (anchorRect.width / 2) - (tooltipRect.width / 2);
        y = anchorRect.bottom + offsetY;
        break;
      case "top":
      default:
        x = anchorRect.left + (anchorRect.width / 2) - (tooltipRect.width / 2);
        y = anchorRect.top - tooltipRect.height - offsetY;
    }

    tooltip.style.left = `${Math.round(x)}px`;
    tooltip.style.top = `${Math.round(y)}px`;
  }
}
