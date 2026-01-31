import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-manager"
export default class extends Controller {
  static targets = [ "menu", "trigger" ];
  static values = { position: String, triggerAction: String };

  connect() {
    this.xOffset = 12;
    this.yOffset = 12;

    this.boundToggle = this.toggle.bind(this);
    this.boundOpen = this.open.bind(this);
    this.boundClose = this.close.bind(this);

    switch (this.triggerActionValue) {
      case "hover":
        this.triggerTarget.addEventListener("mouseenter", this.boundOpen);
        this.triggerTarget.addEventListener("mouseleave", this.boundClose);
        this.menuTarget.addEventListener("mouseenter", this.boundOpen);
        this.menuTarget.addEventListener("mouseleave", this.boundClose);
        break;
      case "click":
      default:
        this.triggerTarget.addEventListener("click", this.boundToggle);
        break;
    }
  }

  toggle() {
    this.isOpen() ? this.close() : this.open();
  }

  open() {
    this.menuTarget.classList.remove("hidden");
    this.position();
  }

  close(event) {
    if (event?.type === "click") {
      if (this.element.contains(event.target)) return;
    }
    if (event?.type === "keydown" && event.key !== "Escape") return;

    this.menuTarget.classList.add("hidden");
    document.removeEventListener("click", this.boundClose);
    document.removeEventListener("keydown", this.boundClose);
  }

  isOpen() {
    return !this.menuTarget.classList.contains("hidden");
  }

  handleKey(e) {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.toggle();
    }
  }

  position() {
    const wrapperRect = this.element.getBoundingClientRect(); // need relative pos of wrapper
    const tRect = this.triggerTarget.getBoundingClientRect();
    const mRect = this.menuTarget.getBoundingClientRect();

    let top = 0;
    let left = 0;
    const [primary, align] = this.positionValue.split("-");

    // Primary axis placement
    switch (primary) {
      case "right":
        left = tRect.right - wrapperRect.left + this.xOffset;
        break;
      case "left":
        left = tRect.left - wrapperRect.left - mRect.width - this.xOffset;
        break;
      case "top":
        top = tRect.top - wrapperRect.top - mRect.height - this.yOffset;
        break;
      case "bottom":
      default:
        top = tRect.bottom - wrapperRect.top + this.yOffset;
        break;
    }

    // Secondary axis alignment
    switch (primary) {
      case "left":
      case "right":
        if (align === "start") top = tRect.top - wrapperRect.top;
        else if (align === "end") top = tRect.bottom - wrapperRect.top - mRect.height;
        else top = tRect.top - wrapperRect.top + (tRect.height / 2) - (mRect.height / 2);
        break;

      case "bottom":
      case "top":
      default:
        if (align === "start") left = tRect.left - wrapperRect.left;
        else if (align === "end") left = tRect.right - wrapperRect.left - mRect.width;
        else left = tRect.left - wrapperRect.left + (tRect.width / 2) - (mRect.width / 2);
        break;
    }

    this.menuTarget.style.left = `${left}px`;
    this.menuTarget.style.top = `${top}px`;
  }
}
