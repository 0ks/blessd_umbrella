import socket from "../socket"
import Mousetrap from "mousetrap"

let channel;

if (socket) {
  channel = socket.channel("attendance:lobby", {})
}

export default class AttendanceView {
  static index() {
    channel.join()
      .receive("ok", _ => {
        console.log("Joined successfully")

        const table = document.querySelector(".js-people");
        const search = document.querySelector(".js-search");
        const tableBody = table.querySelector(".js-people-body");
        AttendanceView.addCheckboxesListener(tableBody)
        AttendanceView.addSearchListener(search, tableBody)

        AttendanceView.bindKeys(tableBody)
        AttendanceView.bindRowHover(tableBody)
        AttendanceView.bindRowClick(tableBody)
      })
      .receive("error", resp => { console.error("Unable to join", resp) });
  }

  static addCheckboxesListener(tableBody) {
    tableBody.addEventListener("change", event => {
      const checkbox = event.target;

      AttendanceView.toggleAttendant(
        checkbox.getAttribute("data-person-id"),
        tableBody.getAttribute("data-occurrence-id")
      );
    });
  }

  static toggleAttendant(personId, occurrenceId) {
    channel
      .push("toggle", {
        person_id: personId,
        meeting_occurrence_id: occurrenceId
      })
      .receive("ok", _ => console.log("Toggled attendant", _))
      .receive("error", reason => console.error("Unable to toggle attendant", reason))
      .receive("timeout", _ => console.error("Networking issue..."));
  }

  static addSearchListener(input, tableBody) {
    input.addEventListener("keydown", event => {
      if ([13, 38, 40].includes(event.keyCode)) event.preventDefault();
    });

    input.addEventListener("keyup", event => {
      if (![13, 38, 40].includes(event.keyCode)) {
        const occurrenceId = tableBody.getAttribute("data-occurrence-id");

        AttendanceView.searchPeople(occurrenceId, input.value, resp => {
          tableBody.innerHTML = resp.table_body;
          AttendanceView.selectRow(tableBody, 0);

          // needs to be rebound because it depends on the inner content
          AttendanceView.bindRowHover(tableBody);
        });
      }
    })
  }

  static searchPeople(occurrenceId, query, callback) {
    channel
      .push("search", {
        meeting_occurrence_id: occurrenceId,
        query: query
      })
      .receive("ok", callback)
      .receive("error", reason => console.error("Unable to search people", reason))
      .receive("timeout", _ => console.error("Networking issue..."));
  }

  static keyUp(tableBody) {
    const row = AttendanceView.getRow(tableBody);
    if (row) {
      const prev = row.previousElementSibling;
      if (prev) {
        row.classList.remove("nav-focus");
        prev.classList.add("nav-focus");
      }
    } else {
      AttendanceView.selectRow(tableBody, tableBody.children.length-1);
    }
  }

  static keyDown(tableBody) {
    const row = AttendanceView.getRow(tableBody);
    if (row) {
      const next = row.nextElementSibling;
      if (next) {
        row.classList.remove("nav-focus");
        next.classList.add("nav-focus");
      }
    } else {
      AttendanceView.selectRow(tableBody, 0);
    }
  }

  static keyEnter(tableBody) {
    const row = AttendanceView.getRow(tableBody);
    const occurrenceId = tableBody.getAttribute("data-occurrence-id");
    if (row) AttendanceView.toggleRowCheckbox(row, occurrenceId);
  }

  static bindKeys(tableBody) {
    const mousetrap = new Mousetrap(document.body);
    mousetrap.bind("up", _ => AttendanceView.keyUp(tableBody));
    mousetrap.bind("down", _ => AttendanceView.keyDown(tableBody));
    mousetrap.bind("enter", _ => AttendanceView.keyEnter(tableBody));
  }

  static bindRowHover(tableBody) {
    const rows = tableBody.querySelectorAll(".js-person");

    for (let row of rows) {
      row.addEventListener("mouseenter", event => {
        const selectedRow = AttendanceView.getRow(tableBody);
        if (selectedRow) selectedRow.classList.remove("nav-focus");
        event.target.classList.add("nav-focus");
      });
    }
  }

  static selectRow(tableBody, index) {
    const row = AttendanceView.getRow(tableBody);
    if (row) row.classList.remove("nav-focus");

    const firstRow = tableBody.children[index];
    if (firstRow) firstRow.classList.add("nav-focus");
  }

  static getRow(tableBody) {
    return tableBody.querySelector(".nav-focus");
  }

  static bindRowClick(tableBody) {
    tableBody.addEventListener("click", event => {
      const occurrenceId = tableBody.getAttribute("data-occurrence-id");
      AttendanceView.toggleRowCheckbox(event.target.parentElement, occurrenceId)
    });
  }

  static toggleRowCheckbox(tr, occurrenceId) {
    const checkbox = tr.querySelector(".js-person-is-present");
    checkbox.checked = !checkbox.checked;
    AttendanceView.toggleAttendant(
      checkbox.getAttribute("data-person-id"),
      occurrenceId
    );
  }
}
