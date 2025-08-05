import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-upload"
export default class extends Controller {
  static values = {
    acceptedFileTypes: Array,
  }

  connect() {
    this.track_uploaded_classes = [
      "bg-accent",
      "dark:bg-accent",
      "text-white",
      "dark:text-white",
      "border-none"
    ];
  }

  track_upload(event) {
    const label = event.target.closest("label");
    const uploadedFile = event.target.files[0];
    const fileType = uploadedFile ? uploadedFile.type : null;

    if (acceptedFileTypes.includes(fileType)) {
      label.classList.remove("dark:bg-secondary-bg");
      this.track_uploaded_classes.forEach((className) => {
        label.classList.add(className);
      });
    } else {
      alert("Invalid file type.");
    }
  }
}
