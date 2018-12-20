// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

export default class BlessdSocket {
  constructor() {
    this.socket = new Socket("/socket", {params: {token: window.currentUserToken}});
    this.modal = document.querySelector(".js-socket-disconnect-modal");

    const self = this;

    this.socket.onError(_ => {
      self.modal.classList.add("is-active");
      console.error("There was an error on the websocket connection");
    });

    this.socket.onClose(_ => {
      self.modal.classList.add("is-active");
      console.info("Socket was disconnected gracefully");
    });

    this.socket.onOpen(_ => {
      self.modal.classList.remove("is-active");
      console.info("Connected to socket");
    });
  }

  connect() {
    return this.socket.connect();
  }

  channel(topic, params) {
    return this.socket.channel(topic, params);
  }
}
