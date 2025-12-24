import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio"
export default class extends Controller {
  connect() {
    console.log(this)
  }

  async play(e) {
    const el = e.target.closest("[data-prevent-play]");
    if (el && el.dataset.preventPlay === "true") return;
    await this.playerOutlet.playAudio(parseInt(e.currentTarget.dataset.trackId));
  }

  async playAudio(trackId) {
    if (this.played) {
      if (this.currentTrackId == trackId) {
        if (this.audioTarget.paused) {
          this.resumeAudio();
        }

        this.openPlayer();
        return;
      }
    }

    if (this.playController) this.playController.abort();
    this.playController = new AbortController();
    const playable = await fetch(`${this.trackDataApiUrl}/${trackId}`, {
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

        this.togglePlayableCoverPhotoIcon(false);
        this.played = false;
        return false;
      }

      this.coverPhotoTarget.classList.add("hidden");
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
      this.resetAudio();
      this.resumeAudio();
      this.played = true;
      return true;
    })
    .catch(error => {
      console.error("Error fetching track: " + error.message);
      return false;
    })

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
