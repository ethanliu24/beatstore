import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"
import '@cropper/element';
import '@cropper/element-canvas';
import '@cropper/element-image';
import '@cropper/element-selection';
import '@cropper/element-handle';
import '@cropper/element-grid';
import '@cropper/element-crosshair';

// Connects to data-controller="crop"
export default class extends Controller {
  static targets = ["image"]

  connect() {
    this.cropper = null;

    document.addEventListener("image:uploaded", () => {
      // this.cropper = new Cropper(this.imageTarget);
      this.createCroppingArea();
    })
  }

  createCroppingArea() {
    const cropperCanvas = document.createElement("cropper-canvas");

    const cropperImage = document.createElement("cropper-image");
    cropperImage.src = this.imageTarget.src;
    cropperImage.setAttribute("initial-center-size", "contain");
    cropperImage.setAttribute("rotatable", "");
    cropperImage.setAttribute("scalable", "");
    cropperImage.setAttribute("translatable", "");

    const cropperShade = document.createElement("cropper-shade");

    const cropperSelection = document.createElement("cropper-selection");
    cropperSelection.setAttribute("initial-coverage", "1");
    cropperSelection.setAttribute("movable", "");
    cropperSelection.setAttribute("resizable", "");
    cropperSelection.setAttribute("aspect-ratio", "1");

    const cropperGrid = document.createElement("cropper-grid");
    cropperGrid.setAttribute("covered", "");
    cropperSelection.appendChild(cropperGrid);

    const crosshair = document.createElement("cropper-crosshair");
    crosshair.setAttribute("centered", "");
    cropperSelection.appendChild(crosshair);

    const moveHandle = document.createElement("cropper-handle");
    moveHandle.setAttribute("action", "move");
    moveHandle.setAttribute("theme-color", "rgba(0,0,0,0)");
    cropperSelection.appendChild(moveHandle);

    cropperCanvas.appendChild(cropperImage);
    cropperCanvas.appendChild(cropperShade);
    cropperCanvas.appendChild(cropperSelection);

    const container = document.getElementById("image-modal-cropper-container")
    container.replaceChildren();
    container.appendChild(cropperCanvas);

    // this.boundArea(cropperSelection, cropperImage, cropperCanvas);
  }

  boundArea(selection, image, canvas) {
    selection.addEventListener("change", (event) => {
      const selectionRect = selection.getBoundingClientRect();
      const imageRect = image.getBoundingClientRect();

      if (!this.inSelection(selectionRect, imageRect)) {
        // event.preventDefault();
      }

      // selection.x = 0;

      // selection.y = 0;
    })
  }

  inSelection(selection, image) {
    console.log(selection, image)

    // return (
    //   selection.left >= image.left &&
    //   selection.top >= image.top &&
    //   selection.right <= image.right &&
    //   selection.bottom <= image.bottom
    // );
    return (
      selection.x >= image.left &&
      selection.top >= image.top &&
      (selection.x + selection.width) <= (image.right) &&
      (selection.top + selection.height) <= (image.bottom)
    );
  }

  disconnect() {
    this.cropper?.destroy();
  }
}
