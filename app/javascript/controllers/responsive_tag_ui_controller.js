import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="responsive-tag-ui"
export default class extends Controller {
  static targets = ["tagsContainer", "tag"];

  connect() {
    this.render();
  }

  render() {
    this.tagsContainerTarget.classList.add("opacity-0");
    this.tagsContainerTarget.classList.remove("justify-end");

    const container = this.tagsContainerTarget.getBoundingClientRect();
    const conatinerLeft = container.left;
    const containerRight = container.right;

    for (let i = 0; i < this.tagTargets.length; i++) {
      const tag = this.tagTargets[i];
      const tagRect = tag.getBoundingClientRect();

      if (!this.#inRange(conatinerLeft, containerRight, tagRect.left, tagRect.right)) {
        tag.classList.add("hidden");
      } else {
        tag.classList.remove("hidden");
      }
    }

    this.tagsContainerTarget.classList.add("justify-end");
    this.tagsContainerTarget.classList.remove("opacity-0");
  }

  #inRange(boundLeft, boundRight, left, right) {
    return boundLeft <= left && right <= boundRight;
  }
}
