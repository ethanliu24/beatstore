import { Controller } from "@hotwired/stimulus"
import { dispatchCloseModalEvent } from "helpers/modal_helper"

// Connects to data-controller="one-time-close-modal"
export default class extends Controller {
  // Good in turbo stream actions. Cannot use click->modalManager#close
  // becuase that would remove the modal before sending the request.
  connect() {
    dispatchCloseModalEvent();
    this.element.remove();
  }
}
