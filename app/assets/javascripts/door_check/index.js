import PasskeyController from "door_check/passkey_controller"

export function registerControllers(application) {
  application.register("door-check-passkey", PasskeyController)
}
