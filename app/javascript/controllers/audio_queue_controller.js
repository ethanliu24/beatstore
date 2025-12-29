import { Controller } from "@hotwired/stimulus"
import { PlayerModes } from "helpers/audio_player"

// Connects to data-controller="audio-queue"
export default class extends Controller {
  static targets = ["list"];

  connect() {
    this.queue = [];
    this.activeScopeCtx = null;
    this.queueTrackTemplate = document.getElementById("queue-track-template");

    document.addEventListener("update-queue", (e) => this.updateQueue(e.detail.queueScope, true));
  }

  updateQueue(queueScope, ignoreSameCtxCheck = false) {
    if (!ignoreSameCtxCheck && this.activeScopeCtx === queueScope) {
      return;
    }

    this.activeScopeCtx = queueScope;
    const tracks = document.querySelectorAll(`[data-queue-scope="${queueScope}"]`);
    this.queue = Array.from(tracks).map((el, cursor) => {
      return {
        cursor: cursor,
        trackId: Number(el.dataset.trackId),
        title: el.dataset.trackTitle,
        metadata: el.dataset.trackMetadata,
        imageUrl: el.dataset.trackImageUrl
      };
    });

    this.updateTrackDOM();
  }

  pickTrack(mode, trackId) {
    const cursor = this.getTrackCursor(trackId);
    if (cursor === null) return null;

    switch (mode) {
      case PlayerModes.NEXT:
        return this.pickNextTrack(cursor);
      case PlayerModes.REPEAT:
        return this.pickCurrentTrack(cursor);
      case PlayerModes.SHUFFLE:
        return this.pickNextTrackShuffle(cursor);
      default:
        console.error(`Unknown player mode: ${mode}`);
        return null;
    }
  }

  getTrackCursor(trackId) {
    const track = this.queue.find(t => t.trackId === trackId);
    return track ? track.cursor : null;
  }

  pickNextTrack(cursor) {
    if (!this.queue) return null;

    const nextIndex = (cursor + 1) % this.queue.length;
    const track = this.queue.at(nextIndex);
    return track.trackId;
  }

  pickCurrentTrack(cursor) {
    return !this.queue? null : this.queue.at(cursor).trackId;
  }

  pickNextTrackShuffle(current) {
    if (this.queue.length <= 1) return null;

    const selections = this.queue.filter(t => t.cursor !== current);
    const track = selections[Math.floor(Math.random() * selections.length)];
    return track.trackId;
  }

  updateTrackDOM() {
    this.listTarget.innerHTML = "";
    this.queue.forEach((track) => this.addTrackDOM(track));
  }

  addTrackDOM(track) {
    const node = this.queueTrackTemplate.content.cloneNode(true);

    node.querySelector("[data-queue-track-image]").src = track.imageUrl;
    node.querySelector("[data-queue-track-title]").textContent = track.title;
    node.querySelector("[data-queue-track-metadata]").textContent = track.metadata;

    this.listTarget.appendChild(node);
  }
}
