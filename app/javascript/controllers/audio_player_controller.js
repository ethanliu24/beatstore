import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = ["audio"];
  static values = {
    trackDataApiUrl: String
  }

  connect() {
    this.trackDataApiUrl = this.trackDataApiUrlValue || "api/tracks"
    this.currentTrackId = null;
  }

  play(e) {
    // e.stopPropagation();
    this.playAudio(e.currentTarget.dataset.trackId);
  }

  playAudio(trackId) {
    if (this.currentTrackId == trackId) {
      return;
    }

    this.audioTarget.pause();

    fetch(`${this.trackDataApiUrl}/${trackId}`, {
      method: "GET"
    })
    .then(res => res.json())
    .then(track => {
      this.currentTrackId = track.id
      this.audioTarget.src = track.tagged_mp3;
      this.audioTarget.load();
      this.audioTarget.play();
    });
  }
}
