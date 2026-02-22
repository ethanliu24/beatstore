import DragAndSortController from "controllers/drag_and_sort_controller";

// Connects to data-controller="recommendations-drag"
export default class extends DragAndSortController {
  constructOptions() {
    var options = {
      handle: ".recs-drag-handle",
      animation: 500,
      easing: "cubic-beizer(0.42, 0, 1, 1)",
      dataIdAttr: "data-recommendation-id",
      onUpdate: () => {
        console.log(this.sortable.toArray());
      },
    };

    return options;
  }
}
