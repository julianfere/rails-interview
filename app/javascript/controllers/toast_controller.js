import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Trigger entrance animation on next frame so the CSS transition fires
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.element.classList.add("toast--visible")
      })
    })

    this.timer = setTimeout(() => this.dismiss(), 3500)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.remove("toast--visible")
    this.element.classList.add("toast--hiding")

    this.element.addEventListener("transitionend", () => {
      this.element.remove()
    }, { once: true })
  }
}
