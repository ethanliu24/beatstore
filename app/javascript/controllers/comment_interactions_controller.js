import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-interactions"
export default class extends Controller {
  static targets = [
    "like", "unlike", "likeCount",
    "dislike", "undislike", "dislikeCount",
  ];

  static values = { authorized: Boolean };

  connect() {
    console.log(this.authorizedValue)
    if (this.#loggedIn()) {
      /** Assumes that interaction target is a button and its wrapped inside a form,
       *  as to button_to tag is this structure.
       */
      this.likeBtn = this.likeTarget.parentElement;
      // this.dislikeBtn = this.dislikeTarget.parentElement;
      this.unlikeBtn = this.unlikeTarget.parentElement;
      // this.undislikeBtn = this.undislikeTarget.parentElement;
    }
  }

  like() {
    this.likeBtn.classList.add("hidden");
    this.unlikeBtn.classList.remove("hidden");
    this.likeCountTarget.innerText = `${this.#getLikeCount() + 1}`;
  }

  unlike() {
    this.unlikeBtn.classList.add("hidden");
    this.likeBtn.classList.remove("hidden");
    this.likeCountTarget.innerText = `${this.#getLikeCount() - 1}`;
  }

  #getLikeCount() {
    return parseInt(this.likeCountTarget.innerText, 10);
  }

  #loggedIn() {
    return Boolean(this.authorizedValue);
  }
}
