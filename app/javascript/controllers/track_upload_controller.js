import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-upload"
export default class extends Controller {
  static targets = ["uploaded", "audio", "file", "fileName", "fileSize", "fileInfoSeperator", "removeField"];
  static values = {
    acceptedFileTypes: Array,
  }

  connect() {
  }

  upload(event) {
    const uploadedFile = event.target.files[0];
    const fileType = uploadedFile ? uploadedFile.type : null;

    if (!this.acceptedFileTypesValue.includes(fileType)) {
      alert("Invalid file type.");
      return;
    }

    this.uploadedTarget.classList.remove("text-secondary-txt");
    this.uploadedTarget.classList.add("text-accent");
    this.fileNameTarget.innerHTML = uploadedFile.name;
    this.fileSizeTarget.innerHTML = `${(uploadedFile.size / (1024 * 1024)).toFixed(2)} MB`;
    this.fileInfoSeperatorTarget.classList.remove("hidden");
    if (this.hasAudioTarget) {
      const url = URL.createObjectURL(uploadedFile);
      this.audioTarget.src = url;
    }
  }

  remove() {
    if (!this.#isUploaded()) {
      return;
    }

    if (window.confirm("Remove file?")) {
      this.fileTarget.value = "";
      if (this.hasRemoveFieldTarget) {
        this.removeFieldTarget.value = "1";
      }

      this.uploadedTarget.classList.remove("text-accent");
      this.uploadedTarget.classList.add("text-secondary-txt");
      this.fileNameTarget.innerHTML = "";
      this.fileSizeTarget.innerHTML = "";
      this.fileInfoSeperatorTarget.classList.add("hidden");
      if (this.hasAudioTarget) {
        this.audioTarget.src = "";
      }
    }
  }

  #isUploaded() {
    return this.uploadedTarget.classList.contains("text-accent");
  }
}
