export function dispatchTurboSubmitEndEvent(detail = {}, bubbles = true, cancelable = false) {
  const event = new CustomEvent("turbo:submit-end", {
    bubbles: bubbles,
    cancelable: cancelable,
    detail: detail
  });

  document.dispatchEvent(event);
}
