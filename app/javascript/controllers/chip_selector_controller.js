import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chip-selector"
export default class extends Controller {
  static targets = ["input", "display", "tagValues"];

  connect() {
    this.chips = [];
  }

  handleKeydown(e) {
    if (e.key === "Enter") {
      e.preventDefault();

      const value = this.inputTarget.value.trim();
      if (value !== "" && !this.chips.includes(value)) {
        const chip = { id: null, value: value, _destroy: false }
        this.chips.push(chip);
        this.inputTarget.value = ""
        this.displayChips();
      }
    }
  }

  displayChips() {
    this.displayTarget.replaceChildren();

    this.chips.forEach(({id, value, _destroy}, index) => {
      const chip = value;
      const chipElement = document.createElement("div");
      chipElement.classList.add("chip");
      chipElement.innerText = "#" + chip;

      const closeButton = document.createElement("button");
      closeButton.innerText = "✕";
      closeButton.addEventListener("click", () => {
        // tells rails to destroy the chip
        if (this.chips[index].id) {
          this.chips[index]._destroy = true;
        }

        this.chips.splice(index, 1);
        this.displayChips();
      });

      chipElement.appendChild(closeButton);
      this.displayTarget.appendChild(chipElement);
    });

    this.updateTagValues();
  }

  updateTagValues() {
    this.tagValuesTarget.innerHTML = "";

    this.chips.forEach((chip, index) => {
      if (chip._destroy) {
        // Rails needs a hidden _destroy input to flag deletion
        const destroyInput = document.createElement("input");
        destroyInput.type = "hidden";
        destroyInput.name = `track[tags_attributes][${index}][_destroy]`;
        destroyInput.value = "1";  // "1" or "true" means delete
        this.tagValuesTarget.appendChild(destroyInput);

        // Include id so Rails knows which to delete
        if (chip.id) {
          const idInput = document.createElement("input");
          idInput.type = "hidden";
          idInput.name = `track[tags_attributes][${index}][id]`;
          idInput.value = chip.id;
          this.tagValuesTarget.appendChild(idInput);
        }
      } else {
        // Normal inputs for new or updated tags
        if (chip.id) {
          const idInput = document.createElement("input");
          idInput.type = "hidden";
          idInput.name = `track[tags_attributes][${index}][id]`;
          idInput.value = chip.id;
          this.tagValuesTarget.appendChild(idInput);
        }
        const valueInput = document.createElement("input");
        valueInput.type = "hidden";
        valueInput.name = `track[tags_attributes][${index}][name]`;
        valueInput.value = chip.value;
        this.tagValuesTarget.appendChild(valueInput);
      }
    });
  }
}
