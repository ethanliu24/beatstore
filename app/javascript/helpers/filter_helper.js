export function updateChip(chip, str) {
  const display = chip.querySelector(".track-filter-chip-text");
  display.innerText = str;

  if (str === "") {
    chip.classList.add("hidden");
  } else {
    chip.classList.remove("hidden");
  }
}

export function updateMultiselect(dropdown, chip, showLength = 3) {
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

  updateChip(chip, str);
}

export function clearMultiselect(dropdown, chip) {
  // assumes dropdown is an ul, each elem should be a li
  Array.from(dropdown.children).forEach(li => {
    const container = li.firstElementChild;
    const checkbox = container.firstElementChild;
    checkbox.checked = false;
  });

  chip.classList.add("hidden");
}

export function updateRange(dropdown, chip) {
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

  updateChip(chip, str);
}

export function clearRange(dropdown, chip) {
  const defaultValue = "";
  dropdown.firstElementChild.value = defaultValue;
  dropdown.lastElementChild.value = defaultValue;
  chip.classList.add("hidden");
}
