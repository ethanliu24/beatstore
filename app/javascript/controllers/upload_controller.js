import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload"
export default class extends Controller {
  static targets = ["imgUpload", "imgCover", "imgPlaceholder"];
  static values = {
    imgDestinationId: String,
    fileUploadInputContainerId: String,
    modelField: String,
  }

  connect() {
    this.track_uploaded_classes = [
      "bg-accent",
      "dark:bg-accent",
      "text-white",
      "dark:text-white",
      "border-none"
    ];

    this.handleImageCrop = (e) => this.display_cropped_image(e.detail.cropper);
    document.addEventListener("image:cropped", this.handleImageCrop);
  }

  disconnect() {
    document.removeEventListener("image:cropped", this.handleImageCrop);
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

  display_cropped_image(cropper) {
    if (!cropper) return;

    // get cropped image
    const cropperCanvas = cropper.getCroppedCanvas();
    const croppedImage = cropperCanvas.toDataURL("image/jpeg")

    const imgDestination = document.getElementById(this.imgDestinationIdValue);
    if (!imgDestination) return;
    imgDestination.src = croppedImage;
    imgDestination.classList.remove("hidden");

    this.appendFile(cropper);
  }

  appendFile(cropper) {
    const fileUploadInputContainer = document.getElementById(this.fileUploadInputContainerIdValue);
    fileUploadInputContainer.replaceChildren();

    cropper.getCroppedCanvas().toBlob((blob) => {
      if (!blob) return;

      const filename = `${crypto.randomUUID().replace(/-/g, '')}.png`;
      const file = new File([blob], filename, { type: "image/png" });

      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);

      const newInput = document.createElement("input");
      newInput.type = "file";
      newInput.name = this.modelFieldValue;
      newInput.classList.add("hidden");
      newInput.files = dataTransfer.files;

      fileUploadInputContainer.appendChild(newInput);
    }, "image/jpeg", 1);
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
