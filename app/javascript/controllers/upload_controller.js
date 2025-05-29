import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ["imgUpload", "imgCover", "imgPlaceholder"];

  connect() {
    this.track_uploaded_classes = [
      "bg-accent",
      "dark:bg-accent",
      "text-white",
      "dark:text-white",
      "border-none"
    ];
  }

  image_upload() {
    this.imgCoverTarget.src = URL.createObjectURL(this.imgUploadTarget.files[0]);
    this.imgCoverTarget.classList.remove("hidden");
    this.imgPlaceholderTarget.classList.add("hidden");
  }

  track_upload(event) {
    const label = event.target.closest("label");
    label.classList.remove("dark:bg-secondary-bg");
    this.track_uploaded_classes.forEach((className) => {
      label.classList.add(className);
    })
  }
}
