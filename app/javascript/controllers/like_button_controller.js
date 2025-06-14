import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="like-button"
export default class extends Controller {
  static targets = ["liked", "notLiked"];
  static values = {
    userLiked: Boolean,
  }

  connect() {
    this.showButton();
  }

  toggle() {
    this.userLikedValue = !this.userLikedValue;
    this.showButton();
  }

  showButton() {
    if (this.userLikedValue) {
      this.likedTarget.classList.remove("hidden")
      this.notLikedTarget.classList.add("hidden")
    } else {
      this.notLikedTarget.classList.remove("hidden")
      this.likedTarget.classList.add("hidden")
    }
  }
}
