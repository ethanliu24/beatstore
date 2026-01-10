import { Controller } from "@hotwired/stimulus"
import { PlayerModes } from "helpers/audio_player"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static outlets = ["audio", "audio-queue"];
  static targets = [
    "container", "audio",
    "title", "bpm", "key", "coverPhoto",
    "pauseBtn", "resumeBtn", "prevBtn", "nextBtn", "repeatBtn", "playerModeContainer",
    "progressBar",
    "likeBtn", "unlikeBtn", "volumeOnBtn", "volumeOffBtn", "volumeBar",
    "priceBtn",
  ];

  connect() {
    requestAnimationFrame(() => {
      this.containerTarget.classList.remove("slide-up-fade-in");
      this.currentTrackId = parseInt(localStorage.getItem("cur_player_track")) || null;
      this.played = false;
      this.PLAYER_MODES = [PlayerModes.NEXT, PlayerModes.REPEAT, PlayerModes.SHUFFLE];
      this.playerMode = this.PLAYER_MODES[0]; // next
      this.history = []; // history of track ids played
      this.historyIndex = null;

      document.addEventListener("keydown", (e) => {
        if (this.playerOpened()) {
          if (e.key === " ") {
            this.isPlaying() ? this.pauseAudio() : this.resumeAudio();
            e.preventDefault();
          }
        }
      });

      this.audioTarget.addEventListener("timeupdate", () => {
        if (this.audioTarget.duration > 0) {
          const percentage = (this.audioTarget.currentTime / this.audioTarget.duration) * 100;
          this.progressBarTarget.value = percentage;
        }
      });

      this.audioTarget.addEventListener("ended", () => {
        const nextId = this.audioQueueOutlet.pickTrack(this.playerMode, this.currentTrackId);

        if (nextId === null) {
          console.error("Unable to handle 'ended' event");
          return;
        };

        this.audioOutlet.playAudio(nextId);
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
    return localStorage.getItem("player_opened") === "true";
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

  toggleLikeButton(liked) {
    if (liked) {
      this.unlikeBtnTarget.classList.remove("hidden");
      this.likeBtnTarget.classList.add("hidden");
    } else {
      this.unlikeBtnTarget.classList.add("hidden");
      this.likeBtnTarget.classList.remove("hidden");
    }
  }

  addToHistory(trackId) {
    if (this.history.length == 0 || this.history.at(-1) !== trackId) {
      this.history.push(trackId);
    }

    // TODO truncate everything after history index
    this.historyIndex = this.history.length - 1;
  }

  prevTrack() {
    if (this.history.length === 0 || this.historyIndex === 0) {
      return;
    }

    this.historyIndex -= 1;
    const trackId = this.history[this.historyIndex];
    this.audioOutlet.playAudio(trackId, true);
  }

  nextTrack() {
    let trackFromHistory;
    let trackId;

    if (this.historyIndex === this.history.length - 1) {
      trackId = this.audioQueueOutlet.pickTrack(PlayerModes.NEXT, this.currentTrackId);

      if (nextId === null) {
        console.error("Unable to handle 'ended' event");
        return;
      };

      trackFromHistory = false;
    } else {
      this.historyIndex += 1;
      trackId = this.history[this.historyIndex];
      trackFromHistory = true;
    }

    this.audioOutlet.playAudio(trackId, trackFromHistory);
  }

  setTrackInformation(track) {
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
    this.resetAudio();
    this.resumeAudio();
    this.played = true;
  }

  playFailed() {
    this.audioPlayerOutlet.togglePlayableCoverPhotoIcon(false);
    this.played = false;
  }
}
