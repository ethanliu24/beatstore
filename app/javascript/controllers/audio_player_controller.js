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
    trackDataApiUrl: String
  }

  connect() {
    requestAnimationFrame(() => {
      this.containerTarget.classList.remove("slide-up-fade-in");
      this.trackDataApiUrl = this.trackDataApiUrlValue || "/api/tracks"
      this.currentTrackId = parseInt(localStorage.getItem("cur_player_track")) || null;
      this.played = false;
      this.playerMode = "next";
      this.PLAYER_MODES = ["next", "repeat", "shuffle"];

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
    if (localStorage.getItem("player_opened") !== "true") {
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

  stopPropagation(e) {
    e.stopPropagation();
  }

  async play(e) {
    await this.#playAudio(parseInt(e.currentTarget.dataset.trackId));
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

  navToTrack(e) {
    const navTrackId = parseInt(e.currentTarget.dataset.trackId);
    Turbo.visit(`/tracks/${navTrackId}`);
    this.stopPropagation(e);
  }

  async downloadTrack() {
    try {
      const url = `/download/track/${this.currentTrackId}/free`;
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Content-Type": "audio/mpeg"
        }
      });

      if (!response.ok) {
        throw new Error(`Download failed with status ${response.status}`);
      }

      const contentDisposition = response.headers.get("Content-Disposition");
      if (!contentDisposition || !contentDisposition.includes("filename=")) {
        throw new Error("Filename missing from response");
      }

      const filenameMatch = contentDisposition.match(/filename="?([^"]+)"?/);
      if (!filenameMatch || !filenameMatch[1]) {
        throw new Error("Could not extract filename");
      }

      const filename = filenameMatch[1];
      const blob = await response.blob();
      const blobUrl = window.URL.createObjectURL(blob);

      const a = document.createElement("a");
      a.href = blobUrl;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      a.remove();

      window.URL.revokeObjectURL(blobUrl);
    } catch (error) {
      console.error("Download error:", error);
      alert("Could not download the file.");
    }
  }

  async #playAudio(trackId) {
    if (this.played) {
      if (this.currentTrackId == trackId) {
        if (this.audioTarget.paused) {
          this.resumeAudio();
        }

        this.openPlayer();
        return;
      }
    }

    const playable = await fetch(`${this.trackDataApiUrl}/${trackId}`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
      }
    })
    .then(async res => {
      if (!res.ok) {
        if (res.status === 404) {
          console.error("No preview available");
        } else {
          console.error(`Error fetching track: ${res.statusText}`);
        }

        this.played = false;
        return false;
      }

      const track = await res.json();

      this.currentTrackId = track.id;
      localStorage.setItem("cur_player_track", track.id);

      if (track.cover_photo_url === "") {
        this.coverPhotoTarget.classList.add("hidden");
      } else {
        this.coverPhotoTarget.src = track.cover_photo_url;
        this.coverPhotoTarget.classList.remove("hidden");
      }
      this.titleTarget.innerText = track.title;
      this.keyTarget.innerText = track.key;
      this.bpmTarget.innerText = `${track.bpm} BPM`;
      this.priceBtnTarget.innerText = track.cheapest_price;
      this.toggleLikeButton(track.liked_by_user);
      this.pauseAudio();
      this.resetAudio();
      this.openPlayer();
      this.audioTarget.src = track.preview_url;
      this.audioTarget.load();
      this.resumeAudio();
      this.played = true;
      return true;
    })
    .catch(error => {
      alert("Error fetching track: " + error.message);
      return false;
    });

    if (!playable || !this.currentTrackId) return;
    fetch(`/tracks/${this.currentTrackId}/play`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    })
  }
}
