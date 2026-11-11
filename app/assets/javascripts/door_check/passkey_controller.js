import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["credential"]
  static values = { options: Object, ceremony: String }

  async run(event) {
    if (this.credentialTarget.value) return

    event.preventDefault()
    const credential = await this.askBrowser()
    if (!credential) return

    this.credentialTarget.value = JSON.stringify(credential.toJSON())
    this.element.requestSubmit()
  }

  askBrowser() {
    if (this.ceremonyValue === "create") {
      return navigator.credentials.create({ publicKey: PublicKeyCredential.parseCreationOptionsFromJSON(this.optionsValue) })
    }
    return navigator.credentials.get({ publicKey: PublicKeyCredential.parseRequestOptionsFromJSON(this.optionsValue) })
  }
}
