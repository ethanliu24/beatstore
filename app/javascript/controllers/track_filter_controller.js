import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-filter"
export default class extends Controller {
  static targets = [
    "genreDropdown", "keyDropdown", "tagDropdown",
    "genreChip", "keyChip", "tagChip",
  ];

  connect() {
    this.updateGenre();
  }

  updateGenres() {
    this.#updateSelection(this.genreDropdownTarget, this.genreChipTarget, 3);
  }

  updateKeys() {
    this.#updateSelection(this.keyDropdownTarget, this.keyChipTarget, 2);
  }

  updateTags() {
    this.#updateSelection(this.tagDropdownTarget, this.tagChipTarget, 5);
  }

  clearGenres() {
    this.#clearSelection(this.genreDropdownTarget, this.genreChipTarget);
  }

  clearKeys() {
    this.#clearSelection(this.keyDropdownTarget, this.keyChipTarget);
  }

  clearTags() {
    this.#clearSelection(this.tagDropdownTarget, this.tagChipTarget);
  }

  #updateSelection(dropdown, chip, showLength = 3) {
    const selections = Array.from(dropdown.children).reduce((acc, li) => {
      const container = li.firstElementChild;
      const checkbox = container.firstElementChild;
      const label = container.lastElementChild;
      if (checkbox.checked) acc.push(label.innerText.trim());
      return acc;
    }, []);
    console.log(selections)
    let str = "";
    if (selections.length > showLength) {
      const remainingLength = selections.length - showLength;
      str = `${selections.slice(0, showLength).join(", ")}, +${remainingLength}`;
    } else if (selections.length > 0) {
      str = selections.join(", ");
    }
    str = str.trim()
    const display = chip.querySelector(".track-filter-chip-text");
    display.innerText = str;

    if (str === "") {
      chip.classList.add("hidden");
    } else {
      chip.classList.remove("hidden");
    }
  }

  #clearSelection(dropdown, chip) {
    // assumes dropdown is an ul, each elem should be a li
    Array.from(dropdown.children).forEach(li => {
      const container = li.firstElementChild;
      const checkbox = container.firstElementChild;
      checkbox.checked = false;
    });

    chip.classList.add("hidden");
  }
}
