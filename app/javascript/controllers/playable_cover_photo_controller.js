import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playable-cover-photo"
export default class extends Controller {
  static targets = ["container", "playTrigger"];

  connect() {
    this.handleHover = this.handleHover.bind(this);
    this.handleUnhover = this.handleUnhover.bind(this);
    this.containerTarget.addEventListener("mouseenter", this.handleHover);
    this.containerTarget.addEventListener("mouseleave", this.handleUnhover);
  }

  disconnect() {
    this.containerTarget.removeEventListener("mouseenter", this.handleHover);
    this.containerTarget.removeEventListener("mouseleave", this.handleUnhover);
  }

  handleHover() {
    this.playTriggerTarget.classList.remove("hidden");
  }

  handleUnhover() {
    this.playTriggerTarget.classList.add("hidden");
  }
}
