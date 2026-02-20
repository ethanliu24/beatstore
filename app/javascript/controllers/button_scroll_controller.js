import { Controller } from "@hotwired/stimulus";

// data-controller="button-scroll"
export default class extends Controller {
  static targets = ["container"];

  scrollRight() {
    const el = this.containerTarget;
    this.scrollToNextCard(el, "right");
  }

  scrollLeft() {
    const el = this.containerTarget;
    this.scrollToNextCard(el, "left");
  }

  scrollToNextCard(el, direction) {
    const children = Array.from(el.children);
    if (children.length === 0) return;

    const containerLeft = el.scrollLeft;
    const containerRight = containerLeft + el.clientWidth;

    let target;

    // find first partially cut or hidden card for a direction and scroll to that card
    if (direction === "right") {
      target = children.find(card => {
        const { left, right } = this._cardEdges(el, card);
        return right > containerRight + 1;
      }) || children[children.length - 1];

      this._scrollCardToLeft(el, target);
    } else {
      const reversed = [...children].reverse();
      target = reversed.find(card => {
        const { left, right } = this._cardEdges(el, card);
        return right < containerLeft + 1 || left < containerLeft - 1;
      }) || children[0];

      this._scrollCardToRight(el, target);
    }
  }

  _cardEdges(container, card) {
    const rect = card.getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();

    const left = rect.left - containerRect.left + container.scrollLeft;
    const right = left + rect.width;

    return { left, right };
  }

  _scrollCardToLeft(container, card) {
    const rect = card.getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();
    const left = rect.left - containerRect.left + container.scrollLeft;

    container.scrollTo({
      left,
      behavior: "smooth"
    });
  }

  _scrollCardToRight(container, card) {
    const rect = card.getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();
    const scrollLeft = rect.right - containerRect.right + container.scrollLeft;

    container.scrollTo({
      left: scrollLeft,
      behavior: "smooth"
    });
  }
}