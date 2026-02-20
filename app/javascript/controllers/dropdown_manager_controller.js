import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-manager"
export default class extends Controller {
  static targets = [ "content", "trigger" ];
  static values = { position: String, triggerAction: String };

  connect() {
    this.xOffset = 12;
    this.yOffset = 12;
    this.hoverTimeout = null;

    this.boundToggle = this.toggle.bind(this);
    this.boundOpen = this.open.bind(this);
    this.boundClose = this.close.bind(this);
    this.boundOpenHover = this.openHover.bind(this);
    this.boundCloseHover = this.closeHover.bind(this);

    if (this.triggerActionValue !== "hover" && this.triggerActionValue !== "click") {
      this.triggerAction = "click";
    }

    switch (this.triggerActionValue) {
      case "hover":
        [this.triggerTarget, this.contentTarget].forEach((el) => {
          el.addEventListener("mouseenter", this.boundOpenHover);
          el.addEventListener("mouseleave", this.boundCloseHover);
        });
        break;
      case "click":
      default:
        this.triggerTarget.addEventListener("click", this.boundToggle);
        break;
    }
  }

  disconnect() {
    switch (this.triggerActionValue) {
      case "hover":
        [this.triggerTarget, this.contentTarget].forEach((el) => {
          el.removeEventListener("mouseenter", this.boundOpenHover);
          el.removeEventListener("mouseleave", this.boundCloseHover);
        });
        break;
      case "click":
      default:
        this.triggerTarget.removeEventListener("click", this.boundToggle);
    }

    document.removeEventListener("click", this.boundClickOutside);
  }

  toggle() {
    this.isOpen() ? this.close() : this.open();
  }

  open() {
    this.contentTarget.classList.remove("hidden");
    this.position();

    if (this.triggerActionValue === "click") {
      document.addEventListener("click", this.boundClose);
      document.addEventListener("keydown", this.boundClose);
    }
  }

  close(event) {
    if (event?.type === "click") {
      if (this.element.contains(event.target)) return;
    }
    if (event?.type === "keydown" && event.key !== "Escape") return;

    this.contentTarget.classList.add("hidden");

    if (this.triggerActionValue === "click") {
      document.removeEventListener("click", this.boundClose);
      document.removeEventListener("keydown", this.boundClose);
    }
  }

  openHover() {
    if (this.hoverTimeout) {
      clearTimeout(this.hoverTimeout);
      this.hoverTimeout = null;
    }

    this.open();
  }

  closeHover() {
    this.hoverTimeout = setTimeout(() => {
      this.close();
      this.hoverTimeout = null;
    }, 150);
  }

  isOpen() {
    return !this.contentTarget.classList.contains("hidden");
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
    const mRect = this.contentTarget.getBoundingClientRect();

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

    this.contentTarget.style.left = `${left}px`;
    this.contentTarget.style.top = `${top}px`;
  }
}
