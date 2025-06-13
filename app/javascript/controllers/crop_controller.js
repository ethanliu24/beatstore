import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

// Connects to data-controller="crop"
export default class extends Controller {
  static targets = ["image"]

  connect() {
    this.cropper = null;
    this.handleImageUpload = () => this.initCropper();
    document.addEventListener("image:uploaded", this.handleImageUpload);
  }

  disconnect() {
    this.cropper?.destroy();
    document.removeEventListener("image:uploaded", this.handleImageUpload);
  }

  initCropper() {
    this.cropper = new Cropper(this.imageTarget, {
      aspectRatio: 1,
      dragMode: "move",
      movable: true,
      viewMode: 2,
      autoCropArea: 1.0,
      responsive: true,
      movable: false,
      zoomable: false,
      rotatable: false,
      scalable: false,
      cropBoxResizable: true,
      cropBoxMovable: true,
      background: false,
      guides: true,
      center: true,
      highlight: true,
    });
  }

  cropImage() {
    document.dispatchEvent(new CustomEvent("image:cropped", {
      detail: {
        cropper: this.cropper,
      }
    }));
  }
}
