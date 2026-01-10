import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio"
export default class extends Controller {
  static outlets = ["audio-player", "audio-queue"];

  connect() {
    this.playController = null; // prevent overlapping fetches
  }

  async play(e) {
    const el = e.target.closest("[data-prevent-play]");
    if (el && el.dataset.preventPlay === "true") return;

    const trackId = parseInt(e.currentTarget.dataset.trackId);
    const queueScope = e.currentTarget.dataset.queueScope;

    this.audioQueueOutlet.updateQueue(queueScope);
    await this.playAudio(trackId);
  }

  async playAudio(trackId) {
    const currentTrackId = this.audioPlayerOutlet.currentTrackId;

    if (this.audioPlayerOutlet.played) {
      if (currentTrackId == trackId) {
        if (this.audioPlayerOutlet.audioTarget.paused) {
          this.audioPlayerOutlet.resumeAudio();
        }

        this.audioPlayerOutlet.openPlayer();
        return;
      }
    }

    if (this.playController) this.playController.abort();
    this.playController = new AbortController();
    const playable = await fetch(`${"/api/tracks"}/${trackId}`, {
      method: "GET",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
      },
      signal: this.playController.signal
    })
    .then(async res => {
      if (!res.ok) {
        if (res.status === 404) {
          console.error("No preview available");
        } else {
          console.error(`Error fetching track: ${res.statusText}`);
        }

        this.audioPlayerOutlet.playfailed();
        return false;
      }

      this.audioPlayerOutlet.coverPhotoTarget.classList.add("hidden");
      const track = await res.json();
      this.audioPlayerOutlet.setTrackInformation(track);
      this.audioPlayerOutlet.addToHistory(trackId);

      return true;
    })
    .catch(error => {
      console.error("Error fetching track: " + error.message);
      return false;
    })

    if (!playable || !currentTrackId) return;
    fetch(`/tracks/${currentTrackId}/play`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    })
  }
}
