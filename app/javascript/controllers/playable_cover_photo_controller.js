import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playable-cover-photo"
export default class extends Controller {
  static values = { trackId: Number }
  static targets = ["container", "playTrigger"];

  connect() {
  }

  disconnect() {
  }

  play() {
    const event = new CustomEvent("audio-player:track", {
      bubbles: true,
      detail: {
        trackId: this.trackIdValue
      }
    })

    document.dispatchEvent(event);
  }
}
