import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { registerControllers as registerKeystoneControllers } from "keystone_ui/index"
import { registerControllers as registerDoorCheckControllers } from "door_check/index"

const application = Application.start()
registerKeystoneControllers(application)
registerDoorCheckControllers(application)
