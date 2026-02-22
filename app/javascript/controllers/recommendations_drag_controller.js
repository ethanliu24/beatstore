import DragAndSortController from "controllers/drag_and_sort_controller";

// Connects to data-controller="recommendations-drag"
export default class extends DragAndSortController {
  static values = {
    reorderApiUrl: String
  };

  constructOptions() {
    var options = {
      handle: ".recs-drag-handle",
      animation: 500,
      easing: "cubic-beizer(0.42, 0, 1, 1)",
      dataIdAttr: "data-recommendation-id",
      onUpdate: (e) => {
        const id = parseInt(e.item.dataset.recommendationId);
        const position = parseInt(e.newIndex);
        const url = this.reorderApiUrlValue.replace(":id", id).replace(":position", position);

        fetch(url, {
          method: "PUT",
          headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
            "Content-Type": "application/json",
          },
        })
        .then((res) => {
          if (!res.ok) {
            console.error(`Recommendation reordering failed: ${res.status}`);
          }
        })
        .catch((e) => console.error(e));
      },
    };

    return options;
  }
}
