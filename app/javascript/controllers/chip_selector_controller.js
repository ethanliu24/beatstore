import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chip-selector"
export default class extends Controller {
  static targets = ["input", "display", "tagValues"];
  static values = {
    curTags: Array
  }

  connect() {
    this.chips = [];
    this.curTagsValue.forEach(({id, name}) => {
      this.addChip(name, id);
    })
  }

  handleKeydown(e) {
    if (e.key === "Enter") {
      e.preventDefault();

      const value = this.inputTarget.value.trim();
      if (value !== "" && !this.chips.includes(value)) {
        this.addChip(value);
      }
    }
  }

  addChip(name, id = null) {
    const chip = { id: id, value: name, _destroy: false }
    this.chips.push(chip);
    this.inputTarget.value = ""
    this.displayChips();
  }

  displayChips() {
    this.displayTarget.replaceChildren();

    this.chips.forEach(({id, value, _destroy}, index) => {
      if (_destroy) {
        return;
      }

      const chip = value;
      const chipElement = document.createElement("div");
      ["chip", "text-[0.7rem]", "text-primary-txt"].forEach((className) => chipElement.classList.add(className));
      chipElement.innerText = "#" + chip;

      const closeButton = document.createElement("button");
      closeButton.innerText = "✕";
      closeButton.addEventListener("click", () => {
        if (this.chips[index].id) {
          this.chips[index]._destroy = true;
        } else {
          this.chips.splice(index, 1);
        }

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
        destroyInput.value = "true";  // "1" or "true" means delete
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
