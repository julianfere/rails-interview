import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  backdropClick(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }

  // Called via data-action="turbo:submit-end->modal#onSubmitEnd" on the frame
  onSubmitEnd(event) {
    if (event.detail.success) {
      this.close()
    }
  }
}
