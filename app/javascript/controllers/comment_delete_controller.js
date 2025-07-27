import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-delete"
export default class extends Controller {
  connect() {
  }

  delete() {
    Turbo.visit(window.location.href, { action: "replace" })
    document.addEventListener("turbo:load", () => {
      const el = document.getElementById("comments");
      if (el) el.scrollIntoView({ behavior: "smooth" });
    }, { once: true });
  }
}
