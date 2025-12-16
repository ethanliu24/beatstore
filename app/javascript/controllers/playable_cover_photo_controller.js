import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playable-cover-photo"
export default class extends Controller {
  static values = { trackId: Number }
  static targets = ["container", "play", "pause"];
  static outlets = ["audio-player"];

  connect() {
    document.addEventListener("playable-cover-photo:icon-toggle", (e) => {
      // Receiving this event means the audio player paused. We are only
      // interested in updating the icons to match.
      this.setIcon(false);
      if (e.detail.trackId === this.trackIdValue) {
        this.setIcon(e.detail.playing);
      }
    })
  }

  togglePlay() {
    this.audioPlayerOutlet.isPlaying() ? this.pause() : this.play();
  }

  play() {
    this.audioPlayerOutlet.playAudio(this.trackIdValue);
    this.setIcon(true);
  }

  pause() {
    this.audioPlayerOutlet.pauseAudio();
    this.setIcon(false);
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
