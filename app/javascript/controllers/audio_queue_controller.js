import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-queue"
export default class extends Controller {
  connect() {
    this.queue = new Map();
    this.activeScopeCtx = null;
  }

  updateQueue(queueScope) {
    if (this.activeScopeCtx !== queueScope) {
      this.queue = new Map();
      const tracks = document.querySelectorAll(`[data-queue-scope="${queueScope}"]`);
      this.activeScopeCtx = queueScope;

      Array.from(tracks).forEach((el, cursor) => {
        this.queue.set(cursor, {
          trackId: el.dataset.trackId
        });
      });
    }
  }
}
