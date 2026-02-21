import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recs-tag-select"
export default class extends Controller {
  static targets = ["input"];

  connect() {
    try {
      this.selected = JSON.parse(this.inputTarget.value || "[]");
    } catch {
      this.selected = [];
    }
  }

  toggle(e) {
    const el = e.currentTarget;
    const tagName = el.dataset.tagName;

    if (this.selected.includes(tagName)) {
      this.selected = this.selected.filter(t => t !== tagName);
      el.classList.remove("recs-tag-selected");
      el.classList.add("recs-tag-unselected");
    } else {
      this.selected = [...this.selected, tagName];
      el.classList.remove("recs-tag-unselected");
      el.classList.add("recs-tag-selected");
    }

    this.inputTarget.value = JSON.stringify(this.selected);
  }
}
