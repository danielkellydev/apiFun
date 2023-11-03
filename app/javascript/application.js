import "@hotwired/turbo-rails";

import { Application } from "@hotwired/stimulus";
const application = Application.start();

// Manually register your controllers here
import ModalController from "controllers/modal_controller";
application.register("modal", ModalController);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
