import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-upload"
export default class extends Controller {
  connect() {
  }

  upload(event) {
    const label = event.target.closest("label");
    label.classList.remove("dark:bg-secondary-bg");
    label.classList.add("bg-accent");
    label.classList.add("dark:bg-accent");
    label.classList.add("text-white");
    label.classList.add("dark:text-white");
    label.classList.add("border-none");
  }
}
