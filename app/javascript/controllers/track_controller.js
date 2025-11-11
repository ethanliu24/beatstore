import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track"
export default class extends Controller {
  connect() {
    this.trackId = null;
  }

  play(e) {
    this.trackId = e.currentTarget.dataset.trackId;

    if (!this.trackId) {
      console.error("Invalid track id");
      return;
    }

    window.dispatchEvent(new CustomEvent("audio:play", { detail: { trackId: this.trackId } }))
  }
}
