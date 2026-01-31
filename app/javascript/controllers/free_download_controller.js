import { Controller } from "@hotwired/stimulus"
import { dispatchTurboSubmitEndEvent } from "../helpers/turbo";

// Connects to data-controller="free-download"
export default class extends Controller {
  submit(event) {
    // need these to stop form from submiting directly
    event.preventDefault();
    event.stopImmediatePropagation();

    const form = event.currentTarget;
    const formData = new FormData(form);
    const freeDownloadUrl = form.action;

    fetch(freeDownloadUrl, {
      method: form.method,
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
      body: formData
    })
      .then(res => res.json())
      .then(data => {
        if (data.download_url) {
          window.location.href = data.download_url;
          dispatchTurboSubmitEndEvent();
        }
      })
      .catch(err => {
        console.error("Download error:", err);
        alert("Download error:", err);
      })
  }
}
