import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-queue"
export default class extends Controller {
  connect() {
    this.queue = [];
    this.activeScopeCtx = null;
  }

  updateQueue(queueScope) {
    if (this.activeScopeCtx !== queueScope) {
      const tracks = document.querySelectorAll(`[data-queue-scope="${queueScope}"]`);
      this.activeScopeCtx = queueScope;

      this.queue = Array.from(tracks).map((el, cursor) => {
        return {
          trackId: el.dataset.trackId
        };
      });
    }
  }
}
