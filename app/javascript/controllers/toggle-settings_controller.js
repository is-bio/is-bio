import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]

  initialize() {
    // console.log("Toggle settings controller initialized")
  }

  connect() {
    // console.log("Toggle settings controller connected")
  }

  toggle() {
    // console.log("Toggle method called")

    if (this.contentTarget.classList.contains("d-none")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.contentTarget.classList.remove("d-none")
    this.buttonTarget.textContent = "Hide Settings"
  }

  hide() {
    this.contentTarget.classList.add("d-none")
    this.buttonTarget.textContent = "Show Settings"
  }
}
