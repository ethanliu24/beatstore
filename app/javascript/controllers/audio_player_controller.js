import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = ["audio", "title", "bpm", "key", "coverPhoto"];
  static values = {
    trackDataApiUrl: String
  }

  connect() {
    this.trackDataApiUrl = this.trackDataApiUrlValue || "api/tracks"
    this.currentTrackId = null;
  }

  stopPropagation(e) {
    e.stopPropagation();
  }

  play(e) {
    this.playAudio(e.currentTarget.dataset.trackId);
  }

  playAudio(trackId) {
    if (this.currentTrackId == trackId) {
      if (this.audioTarget.paused) {
        this.audioTarget.play();
      }

      return;
    }

    this.audioTarget.pause();

    fetch(`${this.trackDataApiUrl}/${trackId}`, {
      method: "GET"
    })
    .then(res => res.json())
    .then(track => {
      this.currentTrackId = track.id;
      this.coverPhotoTarget.src = track.cover_photo;
      this.titleTarget.innerText = track.title;
      this.keyTarget.innerText = track.key;
      this.bpmTarget.innerText = track.key;
      this.bpmTarget.innerText = track.key;
      this.audioTarget.src = track.tagged_mp3;
      this.audioTarget.load();
      this.audioTarget.play();
    });
  }
}
