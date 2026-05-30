import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="responsive-tag-ui"
export default class extends Controller {
  static targets = ["tagsContainer", "tag", "dropdownTrigger", "dropdownTag"];

  connect() {
    this.render();
  }

  render() {
    this.tagsContainerTarget.classList.add("opacity-0");
    this.tagsContainerTarget.classList.remove("justify-end");

    const container = this.tagsContainerTarget.getBoundingClientRect();
    const conatinerLeft = container.left;
    const containerRight = container.right;

    var overflow = 0;

    for (let i = 0; i < this.tagTargets.length; i++) {
      const tag = this.tagTargets[i];
      const dropdownTag = this.dropdownTagTargets[i];
      const tagRect = tag.getBoundingClientRect();

      if (this.#inRange(conatinerLeft, containerRight, tagRect.left, tagRect.right)) {
        tag.classList.remove("hidden");
        dropdownTag.classList.add("hidden");
      } else {
        tag.classList.add("hidden");
        dropdownTag.classList.remove("hidden");
        overflow++;
      }
    }

    if (overflow == 0) {
      this.dropdownTriggerTarget.classList.add("hidden");
    } else {
      this.dropdownTriggerTarget.lastElementChild.innerText = `+${overflow}`;
      this.dropdownTriggerTarget.classList.remove("hidden");
    }

    this.tagsContainerTarget.classList.add("justify-end");
    this.tagsContainerTarget.classList.remove("opacity-0");
    this.dropdownTriggerTarget.classList.remove("opacity-0");
  }

  #inRange(boundLeft, boundRight, left, right) {
    return boundLeft <= left && right <= boundRight;
  }
}
