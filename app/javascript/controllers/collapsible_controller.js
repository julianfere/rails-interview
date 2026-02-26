import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  static values  = { open: { type: Boolean, default: false } }

  toggle(event) {
    if (event.target.closest("a, button, form")) return
    this.openValue = !this.openValue
  }

  openValueChanged(isOpen) {
    if (isOpen && this.hasFrameTarget) {
      const frame = this.frameTarget
      if (!frame.getAttribute("src")) {
        frame.setAttribute("src", frame.dataset.lazySrc)
      }
    }
  }
}
