import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-interaction"
export default class extends Controller {
  static targets = [ "interactionContainer", "interact", "uninteract", "interactionCount" ];

  connect() {
    /** Assumes that interaction target is a button and its wrapped inside a form,
     *  as to button_to tag is this structure.
     *  Also assumes that the interaction count DOM element is container's sibling (i.e. on same level),
     *  which is also the last element of the container's parent element.
     */
    this.interactBtn = this.interactTarget.parentElement;
    this.uninteractBtn = this.uninteractTarget.parentElement;
    this.interactionCount = this.interactionContainerTarget.parentElement.lastElementChild;
  }

  interact() {
    this.interactBtn.classList.add("hidden");
    this.uninteractBtn.classList.remove("hidden");
    this.interactionCount.innerText = `${this.#getInteractionCount() + 1}`;
  }

  uninteract() {
    this.uninteractBtn.classList.add("hidden");
    this.interactBtn.classList.remove("hidden");
    this.interactionCount.innerText = `${this.#getInteractionCount() - 1}`;
  }

  #getInteractionCount() {
    return parseInt(this.interactionCount.innerText, 10);
  }
}
