import Sortable from "sortablejs";
import BlessdSocket from "../socket"

export default class CustomFieldView {
  constructor() {
    this.socket = new BlessdSocket();
    this.channel = this.socket.channel("custom_field:lobby", {});
  }

  index() {
    this.sortable();
  }

  new() {
    this.sortable();
  }

  edit() {
    this.sortable();
    document.getElementById("field_type").addEventListener("change", this.showWarning);
    document.querySelector(".js-validations").addEventListener("change", this.showWarning);
  }

  sortable() {
    this.socket.connect();
    this.channel.join()
      .receive("ok", _ => {
        console.log("Joined successfully")

        const fieldList = document.querySelector(".js-field-list");
        Sortable.create(fieldList, {
          onUpdate: () => {
            const resource = fieldList.getAttribute("data-resource");
            const ids = Array.from(fieldList.children).map(field => {
              return parseInt(field.getAttribute("data-id"));
            });
            this.channel
              .push("reorder", {resource: resource, ids: ids})
              .receive("ok", _ => console.log("Reordered fields successfully", _))
              .receive("error", reason => console.error("Unable to reorder fields", reason))
              .receive("timeout", _ => console.error("Networking issue..."));
          }
        })
      })
      .receive("error", resp => { console.error("Unable to join", resp) });
  }

  showWarning() {
    document.querySelector(".js-warning").classList.remove("is-hidden");
    document.querySelector(".js-warning-submit").classList.remove("is-hidden");
    document.querySelector(".js-normal-submit").classList.add("is-hidden");
  }
}

