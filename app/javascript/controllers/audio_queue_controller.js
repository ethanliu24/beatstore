import { Controller } from "@hotwired/stimulus"
import { PlayerModes } from "helpers/audio_player"

// Connects to data-controller="audio-queue"
export default class extends Controller {
  connect() {
    this.queue = [];
    this.activeScopeCtx = null;

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
        trackId: el.dataset.trackId
      };
    });
  }

  pickTrack(mode, cursor) {
    switch (mode) {
      case PlayerModes.NEXT:
        return this.pickNextTrack(cursor);
      case PlayerModes.REPEAT:
        return this.queue.at(cursor).trackId;
      case PlayerModes.SHUFFLE:
        return this.pickNextTrackShuffle(cursor);
      default:
        console.error(`Unknown player mode: ${mode}`);
    }
  }

  pickNextTrack(cursor) {
    const nextIndex = (cursor + 1) % this.queue.length;
    const track = this.queue.at(nextIndex);
    return track.trackId;
  }

  pickNextTrackShuffle(current) {
    const selections = [...this.queue].splice(current, 1);
    const track = selections[Math.floor(Math.random() * this.queue.length)];
    return track.trackId;
  }
}
