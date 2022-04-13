import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'input' ]

  connect() {
    this.inputTarget.addEventListener('keydown', (event) => {
      if (event.key == 'ArrowUp') {
        this.increment()
      } else if (event.key == 'ArrowDown') {
        this.decrement()
      }
    })
  }

  increment() {
    let value = parseInt(this.inputTarget.value, 10)
    value += 1
    this.inputTarget.value = value
  }

  decrement() {
    let value = parseInt(this.inputTarget.value, 10)
    if (value <= 0) { return }
    value -= 1
    this.inputTarget.value = value
  }
}
