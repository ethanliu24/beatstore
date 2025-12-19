import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tooltip-manager"
export default class extends Controller {
  static targets = ["container", "arrowX", "arrowY"];
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
    this.arrowXSize = this.arrowXTarget.getBoundingClientRect();
    this.arrowYSize = this.arrowYTarget.getBoundingClientRect();
    this.hideTooltip();
    this.containerTarget.classList.remove("opacity-0");
    this.offsetX = 16;
    this.offsetY = 12;

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
    this.containerTarget.classList.add("hidden");
  }

  updateTooltipPosition() {
    const tooltip = this.containerTarget;
    const anchorRect = this.anchor.getBoundingClientRect();
    const tooltipRect = this.tooltipSize;
    const offsetX = this.offsetX;
    const offsetY = this.offsetY;
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

    x = Math.round(x);
    y = Math.round(y);

    tooltip.style.left = `${x}px`;
    tooltip.style.top = `${y}px`;

    this.updateArrowPosition(x, y);
  }

  updateArrowPosition(tooltipX, tooltipY) {
    const arrowX = this.arrowXTarget;
    const arrowY = this.arrowYTarget;
    const arrowXRect = this.arrowXSize;
    const arrowYRect = this.arrowYSize;

    const xMid = tooltipX + (this.tooltipSize.width / 2) - (arrowYRect.width / 2);
    const yMid = tooltipY + (this.tooltipSize.height / 2) - (arrowXRect.height / 2);

    if (this.positionValue === "left" || this.positionValue === "right") {
      arrowX.classList.remove("hidden");
      arrowY.classList.add("hidden");
    } else {
      arrowX.classList.add("hidden");
      arrowY.classList.remove("hidden");
    }

    switch (this.positionValue) {
      case "left":
        arrowX.style.left = `${tooltipX + this.tooltipSize.width - 1}px`;
        arrowX.style.top = `${yMid}px`;
        arrowX.style.rotate = `180deg`;
        break;
      case "right":
        arrowX.style.left = `${tooltipX - arrowXRect.width + 1}px`;
        arrowX.style.top = `${yMid}px`;
        arrowX.style.rotate = `0deg`;
        break;
      case "bottom":
        arrowY.style.left = `${xMid}px`;
        arrowY.style.top = `${tooltipY - arrowYRect.height + 1}px`;
        arrowY.style.rotate = `0deg`;
        break;
      case "top":
      default:
        console.log(xMid)
        arrowY.style.left = `${xMid}px`;
        arrowY.style.top = `${tooltipY + this.tooltipSize.height - 1}px`;
        arrowY.style.rotate = `180deg`;
    }
  }
}
