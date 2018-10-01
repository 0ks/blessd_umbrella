import socket from "../socket"
const channel = socket.channel("attendance:lobby", {})

export default class AttendanceView {
  static index() {
    channel.join()
      .receive("ok", _ => {
        console.log("Joined successfully")

        const table = document.querySelector(".js-attendants");
        AttendanceView.addCheckboxesListener(table)

        const search = document.querySelector(".js-search");
        const tableBody = table.querySelector(".js-attendants-body");
        AttendanceView.addSearchListener(search, tableBody)
      })
      .receive("error", resp => { console.error("Unable to join", resp) });
  }

  static addCheckboxesListener(element) {
    element.addEventListener("change", event => {
      const checkbox = event.target;

      AttendanceView.updateAttendant(
        checkbox.getAttribute("data-id"),
        {is_present: checkbox.checked}
      );
    });
  }

  static updateAttendant(id, params) {
    channel
      .push("update", {
        id: id,
        attendant: params
      })
      .receive("ok", _ => console.log("Updated attendant", _))
      .receive("error", reason => console.error("Unable to update attendant", reason))
      .receive("timeout", _ => console.error("Networking issue..."));
  }

  static addSearchListener(input, elementToReplace) {
    input.addEventListener("keyup", event => {
      const serviceId = elementToReplace.getAttribute("data-service-id");

      AttendanceView.searchAttendants(serviceId, input.value, resp => {
        elementToReplace.innerHTML = resp.table_body
      });
    })
  }

  static searchAttendants(serviceId, query, callback) {
    channel
      .push("search", {
        service_id: serviceId,
        query: query
      })
      .receive("ok", callback)
      .receive("error", reason => console.error("Unable to search attendants", reason))
      .receive("timeout", _ => console.error("Networking issue..."));
  }
}
