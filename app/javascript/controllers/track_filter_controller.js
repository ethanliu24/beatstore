import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-filter"
export default class extends Controller {
  static targets = [
    "form",
    "genreDropdown", "genreChip",
    "bpmDropdown", "bpmChip",
    "keyDropdown", "keyChip",
    "tagDropdown", "tagChip",
    "visibilityDropdown", "visibilityChip",
  ];

  connect() {
    this.updateGenres();
    this.updateBPM();
    this.updateKeys();
    this.updateTags();
    this.updateVisibility();
  }

  clearFilter() {
    this.clearGenres();
    this.clearBPM();
    this.clearKeys();
    this.clearTags();
    this.clearVisibility();
    this.formTarget.reset();
  }

  updateGenres() {
    this.#updateSelection(this.genreDropdownTarget, this.genreChipTarget, 3);
  }

  updateBPM() {
    this.#updateRange(this.bpmDropdownTarget, this.bpmChipTarget);
  }

  updateKeys() {
    this.#updateSelection(this.keyDropdownTarget, this.keyChipTarget, 2);
  }

  updateTags() {
    this.#updateSelection(this.tagDropdownTarget, this.tagChipTarget, 5);
  }

  updateVisibility() {
    this.#updateSelection(this.visibilityDropdownTarget, this.visibilityChipTarget, 2);
  }

  clearGenres() {
    this.#clearSelection(this.genreDropdownTarget, this.genreChipTarget);
  }

  clearBPM() {
    this.#clearRange(this.bpmDropdownTarget, this.bpmChipTarget);
  }

  clearKeys() {
    this.#clearSelection(this.keyDropdownTarget, this.keyChipTarget);
  }

  clearTags() {
    this.#clearSelection(this.tagDropdownTarget, this.tagChipTarget);
  }

  clearVisibility() {
    this.#clearSelection(this.visibilityDropdownTarget, this.visibilityChipTarget);
  }

  #updateSelection(dropdown, chip, showLength = 3) {
    const selections = Array.from(dropdown.children).reduce((acc, li) => {
      const container = li.firstElementChild;
      const checkbox = container.firstElementChild;
      const label = container.lastElementChild;
      if (checkbox.checked) acc.push(label.innerText.trim());
      return acc;
    }, []);

    let str = "";
    if (selections.length > showLength) {
      const remainingLength = selections.length - showLength;
      str = `${selections.slice(0, showLength).join(", ")}, +${remainingLength}`;
    } else if (selections.length > 0) {
      str = selections.join(", ");
    }

    this.#updateChip(chip, str);
  }

  #updateRange(dropdown, chip) {
    const lowerbound = dropdown.firstElementChild.value;
    const upperbound = dropdown.lastElementChild.value;

    let str;
    if (!upperbound && !lowerbound) {
      str = "";
    } else if (!lowerbound) {
      str = `≤ ${upperbound}`;
    } else if (!upperbound) {
      str = `≥ ${lowerbound}`;
    } else {
      str = `${lowerbound} - ${upperbound}`;
    }

    this.#updateChip(chip, str);
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

  #clearRange(dropdown, chip) {
    const defaultValue = "";
    dropdown.firstElementChild.value = defaultValue;
    dropdown.lastElementChild.value = defaultValue;
    chip.classList.add("hidden");
  }

  #updateChip(chip, str) {
    const display = chip.querySelector(".track-filter-chip-text");
    display.innerText = str;

    if (str === "") {
      chip.classList.add("hidden");
    } else {
      chip.classList.remove("hidden");
    }
  }
}
