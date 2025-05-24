import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["icon"];

  connect() {
    this.update();
  }

  toggle() {
    if (localStorage.beatstore_theme === "dark") {
      localStorage.beatstore_theme = "light";
    } else {
      localStorage.beatstore_theme = "dark";
    }
    this.update(); // Update the theme and icon
  }

  update() {
    const isDarkMode =
      localStorage.beatstore_theme === "dark" ||
      (!("beatstore_theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches);

    if (isDarkMode) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }

    const iconSize = 20;

    this.iconTarget.innerHTML = isDarkMode
      ? `<svg  xmlns="http://www.w3.org/2000/svg"  width="${iconSize}"  height="${iconSize}"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-moon">
          <path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 3c.132 0 .263 0 .393 0a7.5 7.5 0 0 0 7.92 12.446a9 9 0 1 1 -8.313 -12.454z" />
        </svg>`
      : `<svg  xmlns="http://www.w3.org/2000/svg"  width="${iconSize}"  height="${iconSize}"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-sun">
          <path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 12m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0" />
          <path d="M3 12h1m8 -9v1m8 8h1m-9 8v1m-6.4 -15.4l.7 .7m12.1 -.7l-.7 .7m0 11.4l.7 .7m-12.1 -.7l-.7 .7" />
        </svg>`
  }
}