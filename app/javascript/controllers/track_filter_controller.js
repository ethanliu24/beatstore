import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="track-filter"
export default class extends Controller {
  static targets = [
    "genreDropdown",
    "genreChip"
  ];

  connect() {
    this.updateGenre();
  }

  updateGenre() {
    const selectedGenres = Array.from(this.genreDropdownTarget.children).reduce((genres, li) => {
      const container = li.firstElementChild;
      const checkbox = container.firstElementChild;
      const label = container.lastElementChild;
      if (checkbox.checked) genres.push(label.innerText);
      return genres;
    }, []);

    let genreStr = "";
    if (selectedGenres.length > 3) {
      const remainingLength = selectedGenres.length - 3;
      genreStr = `${selectedGenres.slice(0, 3).join(", ")}, +${remainingLength}`;
    } else if (selectedGenres.length > 0) {
      genreStr = selectedGenres.join(", ");
    }

    if (genreStr === "") {
      this.genreChipTarget.classList.add("hidden");
    } else {
      const genreDisplay = this.genreChipTarget.querySelector(".track-filter-chip-text");
      genreDisplay.innerText = genreStr;
      this.genreChipTarget.classList.remove("hidden");
    }

  }

  clearGenre() {
    // genreDropdown is an ul, each elem should be a li
    Array.from(this.genreDropdownTarget.children).forEach(li => {
      const container = li.firstElementChild;
      const checkbox = container.firstElementChild;
      checkbox.checked = false;
    });

    this.genreChipTarget.classList.add("hidden");
  }
}
