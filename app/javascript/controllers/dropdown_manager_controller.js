import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-manager"
export default class extends Controller {
  static targets = ["menu", "trigger"];
  static values = { id: String };

  connect() {
    this.boundClose = this.close.bind(this);
  }

  toggle() {
    this.isOpen() ? this.close() : this.open();
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.boundClose);
    document.addEventListener("keydown", this.boundClose);
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
}
