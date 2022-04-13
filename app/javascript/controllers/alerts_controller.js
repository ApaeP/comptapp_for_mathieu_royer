import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

export default class extends Controller {
  static values = { message: String }

  connect() {
    this.element.addEventListener('submit', (event) => { this.request(event) })
  }

  request(event) {
    console.log(this.messageValue)
    event.preventDefault()

    Swal.fire({
      title: 'Confirmation',
      text: this.messageValue,
      icon: 'question',
      confirmButtonText: 'Confirmer',
      showCancelButton: true,
      cancelButtonText: 'Annuler'
    }).then((result) => {
      if (result.isConfirmed) {
        this.element.submit()
      }// else if (result.dismiss === Swal.DismissReason.cancel) {
      //   console.log('annulé')
      // }
    })
  }

}
