import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playable-cover-photo"
export default class extends Controller {
  static values = { trackId: Number };
  static targets = ["container", "play", "pause"];
  static outlets = ["audio", "audio-player", "audio-queue"];

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

  togglePlay(e) {
    this.audioPlayerOutlet.isPlaying() ? this.pause() : this.play(e);
  }

  play(e) {
    this.audioOutlet.playAudio(this.trackIdValue);
    this.setIcon(true);

    const queueScope = e.currentTarget.dataset.queueScope;
    this.audioQueueOutlet.updateQueue(queueScope);
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
