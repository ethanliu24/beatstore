import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playable-cover-photo"
export default class extends Controller {
  static values = { trackId: Number }
  static targets = ["container", "play", "pause"];

  connect() {
    this.isPlaying = false;
    document.addEventListener("playable-cover-photo:icon-toggle", (e) => {
      // Receiving this event means the audio player paused. We are only
      // interested in updating the icons to match.
      if (e.detail.trackId === this.trackIdValue) {
        this.setIcon(e.detail.playing);
      }
    })
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
    this.setIcon(true);
    this.isPlaying = true;
  }

  pause() {
    const event = new CustomEvent("audio-player:pause", {
      bubbles: true,
      detail: {
        trackId: this.trackIdValue
      }
     });

    document.dispatchEvent(event);
    this.setIcon(false);
    this.isPlaying = false;
  }

  setIcon(playing) {
    if (playing) {
      this.playTarget.classList.add("hidden");
      this.pauseTarget.classList.remove("hidden");
    } else {
      this.pauseTarget.classList.add("hidden");
      this.playTarget.classList.remove("hidden");
    }
  }
}
