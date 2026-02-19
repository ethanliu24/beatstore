export function dispatchCloseModalEvent(detail = {}, bubbles = true, cancelable = false) {
  const event = new CustomEvent("modal:close", {
    bubbles: bubbles,
    cancelable: cancelable,
    detail: detail
  });

  document.dispatchEvent(event);
}
