import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recommendations-drag"
export default class extends DragAndSortController {
  connect() {
    super();
  }

  constructOptions() {
    var options = {
      handle: ".recs-drag-handle",
      animation: 500,
      easing: "cubic-beizer(0.42, 0, 1, 1)"
    };

    return options;
  }
}
