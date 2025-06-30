import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = [
    "audio",
    "title", "bpm", "key", "coverPhoto",
    "pauseBtn", "resumeBtn"
  ];
  
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
    this.#playAudio(e.currentTarget.dataset.trackId);
  }

  pauseAudio() {
    this.audioTarget.pause();
    this.pauseBtnTarget.classList.add("hidden");
    this.resumeBtnTarget.classList.remove("hidden");
  }

  resumeAudio() {
    this.audioTarget.play();
    this.resumeBtnTarget.classList.add("hidden");
    this.pauseBtnTarget.classList.remove("hidden");
  }

  #playAudio(trackId) {
    if (this.currentTrackId == trackId) {
      if (this.audioTarget.paused) {
        this.audioTarget.play();
      }

      return;
    }

    this.audioTarget.pause();
    this.audioTarget.currentTime = 0;

    fetch(`${this.trackDataApiUrl}/${trackId}`, {
      method: "GET"
    })
    .then(res => res.json())
    .then(track => {
      this.currentTrackId = track.id;
      this.coverPhotoTarget.src = track.cover_photo;
      this.titleTarget.innerText = track.title;
      this.keyTarget.innerText = track.key;
      this.bpmTarget.innerText = `${track.bpm} BPM`;
      this.audioTarget.src = track.tagged_mp3;
      this.audioTarget.load();
      // this.audioTarget.play();
      this.resumeAudio();
    });
  }
}
