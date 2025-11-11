import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track"
export default class extends Controller {
  static values = {
    trackId: Number,
  }

  connect() {
    this.trackId = this.trackIdValue;
    if (!this.trackId) {
      console.error("Invalid track id");
    }
  }

  play() {
    if (this.trackId) {
      window.dispatchEvent(new CustomEvent("audio:play", { detail: { trackId: this.trackId } }))
    }
  }

  navToTrack(e) {
    const navTrackId = parseInt(e.currentTarget.dataset.trackId);
    Turbo.visit(`/tracks/${navTrackId}`);
    e.stopPropagation();
  }
}
