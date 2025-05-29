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
    if (!["image/png", "image/jpeg", "image/jpg"].includes(this.imgUploadTarget.files[0].type)) {
      alert("Accepted file types: PNG, JPEG, JPG");
      return;
    }

    this.imgCoverTarget.src = URL.createObjectURL(this.imgUploadTarget.files[0]);
    this.imgCoverTarget.classList.remove("hidden");
    this.imgPlaceholderTarget.classList.add("hidden");
  }

  track_upload(event) {
    const label = event.target.closest("label");
    const inputId = event.target.id;
    const uploadedFile = event.target.files[0];
    const fileType = uploadedFile ? uploadedFile.type : null;

    if (
      (inputId.includes("mp3") && fileType === "audio/mpeg") ||
      (inputId.includes("wav") && fileType === "audio/wav") ||
      (inputId.includes("stems") && fileType === "application/zip")
    ) {
      label.classList.remove("dark:bg-secondary-bg");
      this.track_uploaded_classes.forEach((className) => {
        label.classList.add(className);
      });
    } else {
      alert("Invalid file type.");
    }
  }
}
