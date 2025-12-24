import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = [
    "container", "audio",
    "title", "bpm", "key", "coverPhoto",
    "pauseBtn", "resumeBtn", "prevBtn", "nextBtn", "repeatBtn", "playerModeContainer",
    "progressBar",
    "likeBtn", "unlikeBtn", "volumeOnBtn", "volumeOffBtn", "volumeBar",
    "priceBtn",
  ];

  static values = {
    trackDataApiUrl: String,
  }

  connect() {
    requestAnimationFrame(() => {
      this.containerTarget.classList.remove("slide-up-fade-in");
      this.trackDataApiUrl = this.trackDataApiUrlValue || "/api/tracks";
      this.currentTrackId = parseInt(localStorage.getItem("cur_player_track")) || null;
      this.played = false;
      this.playerMode = "next";
      this.PLAYER_MODES = ["next", "repeat", "shuffle"];
      this.playController = null; // prevent overlapping fetches

      this.element.addEventListener("keydown", (e) => {
        if (this.playerOpened()) {
          if (e.key === " ") {
            this.isPlaying() ? this.pauseAudio() : this.resumeAudio();
            e.preventDefault();
          }
        }
      });
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
    if (!this.playerOpened()) {
      this.containerTarget.classList.add("slide-up-fade-in");
    }

    localStorage.setItem("player_opened", true);
    this.containerTarget.classList.remove("hidden");
    document.getElementById("main").firstElementChild.classList.add("pb-20");
  }

  closePlayer() {
    localStorage.setItem("player_opened", false);
    this.containerTarget.classList.add("hidden");
    this.containerTarget.classList.remove("slide-up-fade-in");
    document.getElementById("main").classList.remove("pb-20");
    this.audioTarget.pause();
    this.resetAudio();
  }

  playerOpened() {
    return localStorage.getItem("player_opened") === "true"
  }

  stopPropagation(e) {
    e.stopPropagation();
  }

  pauseAudio() {
    this.audioTarget.pause();
    this.pauseBtnTarget.classList.add("hidden");
    this.resumeBtnTarget.classList.remove("hidden");
    this.togglePlayableCoverPhotoIcon(false);
  }

  resumeAudio() {
    this.audioTarget.play();
    this.resumeBtnTarget.classList.add("hidden");
    this.pauseBtnTarget.classList.remove("hidden");
    this.togglePlayableCoverPhotoIcon(true);
  }

  togglePlayableCoverPhotoIcon(playing) {
    const event = new CustomEvent("playable-cover-photo:icon-toggle", {
      detail: {
        trackId: this.currentTrackId,
        playing: playing
      }
    });
    document.dispatchEvent(event);
  }

  isPlaying() {
    return !this.audioTarget.paused;
  }

  resetAudio() {
    this.audioTarget.currentTime = 0;
    this.progressBarTarget.value = 0;
  }

  switchMode() {
    const nextModeIdx = (this.PLAYER_MODES.indexOf(this.playerMode) + 1) % this.PLAYER_MODES.length;
    this.playerMode = this.PLAYER_MODES[nextModeIdx];
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

  toggleLikeButton(liked) {
    if (liked) {
      this.unlikeBtnTarget.classList.remove("hidden");
      this.likeBtnTarget.classList.add("hidden");
    } else {
      this.unlikeBtnTarget.classList.add("hidden");
      this.likeBtnTarget.classList.remove("hidden");
    }
  }

  likeTrack() {
    fetch(`/tracks/${this.currentTrackId}/heart`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    })
    .then();

    this.toggleLikeButton(true);
  }

  unlikeTrack() {
    fetch(`/tracks/${this.currentTrackId}/heart`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    })
    .then();

    this.toggleLikeButton(false);
  }

  async fetchTrackPurchaseModal(e) {
    e.stopPropagation();
    let url = e.currentTarget.dataset.trackPurchaseModalUrl;
    if (!url) {
      if (!this.currentTrackId) return;
      url = `/modal/track_purchase/${this.currentTrackId}`;
    }

    await fetch(url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html));
  }

  downloadTrack() {
    fetch(`/modal/free_download/${this.currentTrackId}`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(err => console.error(err));
  }
}
