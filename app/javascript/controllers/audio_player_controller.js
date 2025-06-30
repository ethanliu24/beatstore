import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = [
    "container", "audio",
    "title", "bpm", "key", "coverPhoto",
    "pauseBtn", "resumeBtn", "prevBtn", "nextBtn", "repeatBtn", "playerModeContainer",
    "progressBar",
    "volumeOnBtn", "volumeOffBtn", "volumeBar"
  ];

  static values = {
    trackDataApiUrl: String
  }

  connect() {
    requestAnimationFrame(() => {
      this.trackDataApiUrl = this.trackDataApiUrlValue || "api/tracks"
      this.currentTrackId = parseInt(localStorage.getItem("cur_player_track")) || null;
      this.played = false;
      this.playerMode = "next";
      this.playerModes = ["next", "repeat", "shuffle"];

      this.audioTarget.addEventListener("ended", () => this.pauseAudio());
      this.audioTarget.addEventListener("timeupdate", () => {
        if (this.audioTarget.duration > 0) {
          const percentage = (this.audioTarget.currentTime / this.audioTarget.duration) * 100;
          this.progressBarTarget.value = percentage;
        }
      });
    });
  }

  openPlayer() {
    this.containerTarget.classList.remove("hidden");
    this.containerTarget.classList.add("slide-up-fade-in");
  }

  closePlayer() {
    this.containerTarget.classList.add("hidden");
    this.containerTarget.classList.remove("slide-up-fade-in");
    this.audioTarget.pause();
    this.resetAudio();
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

  resetAudio() {
    this.audioTarget.currentTime = 0;
    this.progressBarTarget.value = 0;
  }

  switchMode() {
    const nextModeIdx = (this.playerModes.indexOf(this.playerMode) + 1) % this.playerModes.length;
    this.playerMode = this.playerModes[nextModeIdx];
    Array.from(this.playerModeContainerTarget.children).forEach((element) => {
      element.dataset.playerMode === this.playerMode
        ? element.classList.remove("hidden")
        : element.classList.add("hidden");
    });
  }

  repeatTrack() {
    this.resetAudio();
    if (!this.audioTarget.paused) this.resumeAudio();
  }

  seek() {
    const value = this.progressBarTarget.value;
    const duration = this.audioTarget.duration;
    this.audioTarget.currentTime = (value / 100) * duration;
  }

  adjustVolume() {
    this.audioTarget.volume = this.volumeBarTarget.value / 100;
    if (this.audioTarget.volume === 0) {
      this.audioTarget.muted = true;
      this.volumeOnBtnTarget.classList.add("hidden");
      this.volumeOffBtnTarget.classList.remove("hidden");
    } else {
      this.audioTarget.muted = false;
      this.volumeOffBtnTarget.classList.add("hidden");
      this.volumeOnBtnTarget.classList.remove("hidden");
    }
  }

  toggleVolume() {
    if (this.volumeBarTarget.value == 0) {
      return;
    }

    if (this.audioTarget.muted || this.audioTarget.volume === 0) {
      this.audioTarget.volume = this.volumeBarTarget.value / 100;
      this.audioTarget.muted = false;
      this.volumeOffBtnTarget.classList.add("hidden");
      this.volumeOnBtnTarget.classList.remove("hidden");
    } else {
      this.audioTarget.volume = 0;
      this.audioTarget.muted = true;
      this.volumeOnBtnTarget.classList.add("hidden");
      this.volumeOffBtnTarget.classList.remove("hidden");
    }
  }

  goToTrack() {
    Turbo.visit(`/tracks/${this.currentTrackId}`);
  }

  goToEditTrackPage() {
    Turbo.visit(`/admin/tracks/${this.currentTrackId}/edit`);
  }

  #playAudio(trackId) {
    if (this.played) {
      if (this.currentTrackId == trackId) {
        if (this.audioTarget.paused) {
          this.audioTarget.play();
        }

        return;
      }
    }

    this.audioTarget.pause();
    this.resetAudio();
    this.played = true;

    fetch(`${this.trackDataApiUrl}/${trackId}`, {
      method: "GET"
    })
    .then(res => res.json())
    .then(track => {
      this.currentTrackId = track.id;
      localStorage.setItem("cur_player_track", track.id);
      this.coverPhotoTarget.src = track.cover_photo;
      this.titleTarget.innerText = track.title;
      this.keyTarget.innerText = track.key;
      this.bpmTarget.innerText = `${track.bpm} BPM`;
      this.openPlayer();
      this.audioTarget.src = track.tagged_mp3;
      this.audioTarget.load();
      this.resumeAudio();
    });

    // TODO POST to increment play count
  }
}
