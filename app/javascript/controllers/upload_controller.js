import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ["imgUpload", "imgCover", "imgPlaceholder", "imageDestination", "imageDestinationPlaceholder"];
  static values = {
    imgDestinationId: String,
    imgSourceInputId: String,
    fileUploadInputContainerId: String,
    model: String,
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

  image_upload() {
    if (!["image/png", "image/jpeg", "image/jpg"].includes(this.imgUploadTarget.files[0].type)) {
      alert("Accepted file types: PNG, JPEG, JPG");
      return;
    }

    this.imgCoverTarget.src = URL.createObjectURL(this.imgUploadTarget.files[0]);
    this.imgCoverTarget.classList.remove("hidden");
    this.imgPlaceholderTarget.classList.add("hidden");
    this.imgUploadTarget.disabled = true;

    // dispatch event to create cropper tool
    document.dispatchEvent(new CustomEvent('image:uploaded', {}))
  }

  display_cropped_image() {
    const imgSourceInput = document.getElementById(this.imgSourceInputIdValue);
    const imgDestination = document.getElementById(this.imgDestinationIdValue);
    imgDestination.src = URL.createObjectURL(imgSourceInput.files[0]);
    imgDestination.classList.remove("hidden");
    this.appendFile(imgSourceInput)
  }

  appendFile(sourceInput) {
    const fileUploadInputContainer = document.getElementById(this.fileUploadInputContainerIdValue);
    fileUploadInputContainer.replaceChildren();

    const file = sourceInput.files[0]
    if (!file) return;

    const dataTransfer = new DataTransfer();
    dataTransfer.items.add(file);

    const newInput = document.createElement("input");
    newInput.type = "file";
    newInput.name = `${this.modelValue}[cover_photo]`;
    newInput.id = "cover-photo-upload-input";
    newInput.classList.add("hidden");
    newInput.files = dataTransfer.files;

    fileUploadInputContainer.appendChild(newInput);
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
