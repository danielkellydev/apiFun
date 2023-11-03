import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay", "content", "title", "body", "date", "close"];

  connect() {
    console.log("Modal controller connected!");  
  }

  open(event) {
    console.log("Open function triggered!")
    const title = event.currentTarget.getAttribute("data-modal-article-title");
    const body = event.currentTarget.getAttribute("data-modal-article-body");
    const date = event.currentTarget.getAttribute("data-modal-article-date");

    this.titleTarget.innerText = title;
    this.bodyTarget.innerText = body;
    this.dateTarget.innerText = date;

    this.overlayTarget.classList.remove("hidden"); 
}

  close() {
    this.overlayTarget.classList.add("hidden");
  }
}