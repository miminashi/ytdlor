//
// This is a workaround for the problem that video controlls are not shown
//   -> https://discuss.hotwired.dev/t/video-tags-loaded-via-turbo-drive/2746
//

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autoimport"
export default class extends Controller {
  initialize() {
    let v = this.element.content.querySelector("video")
    let src = v.getAttribute("src")
    this.element.replaceWith(this.videoTagWithSrc(src));
  }

  videoTagWithSrc(src) {
    let nv = document.createElement("video")
    nv.setAttribute("controls", "controlls")
    nv.setAttribute("src", src)
    return nv
  }
}
