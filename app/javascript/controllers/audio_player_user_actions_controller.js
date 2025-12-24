import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player-user-actions"
export default class extends Controller {
  static outlets = ["audio-player"];

  connect() {
  }

  currentTrackId() {
    return this.audioPlayerOutlet.currentTrackId;
  }

  goToTrack() {
    Turbo.visit(`/tracks/${this.currentTrackId()}`);
  }

  goToEditTrackPage() {
    Turbo.visit(`/admin/tracks/${this.currentTrackId()}/edit`);
  }

  likeTrack() {
    fetch(`/tracks/${this.currentTrackId()}/heart`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    })
    .then();

    this.audioPlayerOutlet.toggleLikeButton(true);
  }

  unlikeTrack() {
    fetch(`/tracks/${this.currentTrackId()}/heart`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      }
    })
    .then();

    this.audioPlayerOutlet.toggleLikeButton(false);
  }

  async fetchTrackPurchaseModal(e) {
    e.stopPropagation();
    let url = e.currentTarget.dataset.trackPurchaseModalUrl;
    if (!url) {
      if (!this.currentTrackId()) return;
      url = `/modal/track_purchase/${this.currentTrackId()}`;
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
    fetch(`/modal/free_download/${this.currentTrackId()}`, {
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
