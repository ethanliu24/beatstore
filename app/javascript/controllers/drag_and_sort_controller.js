import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs";

// Connects to data-controller="drag-and-sort"
export default class extends Controller {
  static targets = ["list"];

  // Add more if needed, see https://github.com/SortableJS/Sortable
  static values = {
    handle: { type: String, default: null },
    filter: { type: String, default: null },
    animation: { type: Number, default: null },
    easing: { type: String, default: null },
  };

  connect() {
    const options = this.constructOptions();
    this.sortable = Sortable.create(this.listTarget, options);
  }

  constructOptions() {
    var options = {};

    if (this.handleValue) options.handle = this.handleValue
    if (this.filterValue) options.filter = this.filterValue
    if (this.animationValue) options.animation = this.animationValue
    if (this.easingValue) options.easing = this.easingValue

    return options;
  }
}
