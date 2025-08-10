import { Controller } from "@hotwired/stimulus"
import { updateMultiselect, updateRange, clearMultiselect, clearRange } from "helpers/filter_helper"

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
    if (this.hasVisibilityDropdownTarget && this.hasVisibilityChipTarget) this.updateVisibility();
  }

  clearFilter() {
    this.clearGenres();
    this.clearBPM();
    this.clearKeys();
    this.clearTags();
    if (this.hasVisibilityDropdownTarget && this.hasVisibilityChipTarget) this.clearVisibility();
    this.formTarget.reset();
  }

  updateGenres() {
    updateMultiselect(this.genreDropdownTarget, this.genreChipTarget, 3);
  }

  updateBPM() {
    updateRange(this.bpmDropdownTarget, this.bpmChipTarget);
  }

  updateKeys() {
    updateMultiselect(this.keyDropdownTarget, this.keyChipTarget, 2);
  }

  updateTags() {
    updateMultiselect(this.tagDropdownTarget, this.tagChipTarget, 5);
  }

  updateVisibility() {
    updateMultiselect(this.visibilityDropdownTarget, this.visibilityChipTarget, 2);
  }

  clearGenres() {
    clearMultiselect(this.genreDropdownTarget, this.genreChipTarget);
  }

  clearBPM() {
    clearRange(this.bpmDropdownTarget, this.bpmChipTarget);
  }

  clearKeys() {
    clearMultiselect(this.keyDropdownTarget, this.keyChipTarget);
  }

  clearTags() {
    clearMultiselect(this.tagDropdownTarget, this.tagChipTarget);
  }

  clearVisibility() {
    clearMultiselect(this.visibilityDropdownTarget, this.visibilityChipTarget);
  }
}
