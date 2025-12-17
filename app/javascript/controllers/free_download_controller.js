import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="free-download"
export default class extends Controller {
  submit(event) {
    event.preventDefault(); // need this to stop form from submiting directly
    const form = event.currentTarget;
    const formData = new FormData(form);

    fetch(form.action, {
      method: form.method,
      body: formData
    })
      .then(response => {
        if (!response.ok) return response.json().then(err => Promise.reject(err));
        return response.blob(); // audio file
      })
      .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = form.dataset.filename;
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      })
      .catch(err => {
        console.error("Download error:", err)
      })
  }
}
