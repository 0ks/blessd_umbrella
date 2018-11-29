import socket from "../socket"
import Sortable from "sortablejs";

let channel;

if (socket) {
  channel = socket.channel("custom_field:lobby", {})
}

export default class CustomFieldView {
  static index() {
    CustomFieldView.sortable();
  }

  static new() {
    CustomFieldView.sortable();
  }

  static edit() {
    CustomFieldView.sortable();
    document.getElementById("field_type").addEventListener("change", CustomFieldView.showWarning);
    document.querySelector(".js-validations").addEventListener("change", CustomFieldView.showWarning);
  }

  static sortable() {
    channel.join()
      .receive("ok", _ => {
        console.log("Joined successfully")

        const fieldList = document.querySelector(".js-field-list");
        Sortable.create(fieldList, {
          onUpdate: () => {
            const ids = Array.from(fieldList.children).map(field => {
              return parseInt(field.getAttribute("data-id"));
            });
            channel
              .push("reorder", {ids: ids})
              .receive("ok", _ => console.log("Reordered fields successfully", _))
              .receive("error", reason => console.error("Unable to reorder fields", reason))
              .receive("timeout", _ => console.error("Networking issue..."));
          }
        })
      })
      .receive("error", resp => { console.error("Unable to join", resp) });
  }

  static showWarning() {
    document.querySelector(".js-warning").classList.remove("is-hidden");
    document.querySelector(".js-warning-submit").classList.remove("is-hidden");
    document.querySelector(".js-normal-submit").classList.add("is-hidden");
  }
}

