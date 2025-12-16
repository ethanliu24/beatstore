import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playable-cover-photo"
export default class extends Controller {
  static values = { trackId: Number }
  static targets = ["container", "play", "pause"];

  connect() {
    this.isPlaying = false;
  }

  togglePlay() {
    this.isPlaying ? this.pause() : this.play();
  }

  play() {
    const event = new CustomEvent("audio-player:track", {
      bubbles: true,
      detail: {
        trackId: this.trackIdValue
      }
    });

    document.dispatchEvent(event);
    this.isPlaying = true;
    this.playTarget.classList.add("hidden");
    this.pauseTarget.classList.remove("hidden");
  }

  pause() {
    const event = new CustomEvent("audio-player:pause", {
      bubbles: true,
      detail: {
        trackId: this.trackIdValue
      }
     });
     
    document.dispatchEvent(event);
    this.isPlaying = false;
    this.pauseTarget.classList.add("hidden");
    this.playTarget.classList.remove("hidden");
  }
}
