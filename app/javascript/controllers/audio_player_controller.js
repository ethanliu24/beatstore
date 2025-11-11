import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = [
    "container", "audio",
    "pauseBtn", "resumeBtn", "prevBtn", "nextBtn", "repeatBtn", "playerModeContainer",
    "progressBar",
    "volumeOnBtn", "volumeOffBtn", "volumeBar",
  ];

  static values = {
    trackDataApiUrl: String
  }

  connect() {
    this.containerTarget.classList.remove("slide-up-fade-in");
    this.currentTrackId = parseInt(localStorage.getItem("cur_player_track")) || null;
    this.played = false;
    this.playerMode = "next";
    this.PLAYER_MODES = ["next", "repeat", "shuffle"];
    this.attachListeners();
    window.addEventListener("audio:play", this.handleAudioPlayEvent.bind(this));
  }

  attachListeners() {
    const audioTarget = document.getElementById("audio-player-src");
    audioTarget.addEventListener("ended", () => this.repeatTrack());
    audioTarget.addEventListener("timeupdate", () => {
      if (audioTarget.duration > 0) {
        const percentage = (audioTarget.currentTime / audioTarget.duration) * 100;
        this.progressBarTarget.value = percentage;
      }
    });

  }

  disconnect() {
    window.removeEventListener("audio:play", this.handleAudioPlayEvent.bind(this));
  }

  // Expects trackId in detail, i.e. detail: { trackId: trackId }
  handleAudioPlayEvent(e) {
    const { trackId } = e.detail;
    this.playAudio(trackId);
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

  play(e) {
    playAudio(parseInt(e.currentTarget.dataset.trackId));
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

  navToTrack(e) {
    const navTrackId = parseInt(e.currentTarget.dataset.trackId);
    Turbo.visit(`/tracks/${navTrackId}`);
    this.stopPropagation(e);
  }

  async fetchTrackPurchaseModal(e) {
    e.stopPropagation();
    const url = e.currentTarget.dataset.trackPurchaseModalUrl;
    await fetch(url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
      .then();
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

  playAudio(trackId) {
    if (this.played) {
      if (this.currentTrackId == trackId) {
        if (this.audioTarget.paused) {
          this.resumeAudio();
        }

        this.openPlayer();
        return;
      }
    }

    fetch(`/tracks/${trackId}/play`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html",
      }
    })
      .then(res => {
        if (!res.ok) {
          if (res.status === 404) {
            console.error("No preview available");
          } else {
            console.error(`Error fetching track: ${res.statusText}`);
          }

          this.played = false;
          return;
        }

        return res.text();
      })
      .then(html => {
        if (!html) return;
        Turbo.renderStreamMessage(html);
        this.played = true;
        this.currentTrackId = trackId;
        localStorage.setItem("cur_player_track", trackId);
        this.openPlayer();

        requestAnimationFrame(() => {
          this.resetAudio();
          this.attachListeners();
        });
      })
      .catch(err => console.log("Error fetching track: " + err.message));

    return;
  }
}
