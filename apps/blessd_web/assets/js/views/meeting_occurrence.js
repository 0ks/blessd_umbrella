import Mousetrap from "mousetrap"
import BlessdSocket from "../socket"

export default class MeetingOccurrenceView {
  constructor() {
    this.socket = new BlessdSocket();
    this.channel = this.socket.channel("meeting_occurrence:lobby", {});
    this.searchEl = document.querySelector(".js-search");
    this.nameEl = document.getElementById("person_name");
    this.tableEl = document.querySelector(".js-people");
    this.tableBodyEl = this.tableEl.querySelector(".js-people-body");
  }

  show() {
    this.socket.connect();
    this.channel.join()
      .receive("ok", _ => {
        console.info("Joined channel successfully")

        this.addSearchListener();
        this.bindKeys();
        this.bindRowHover();
        this.bindRowClick();
      })
      .receive("error", resp => console.error("Unable to join", resp));
  }

  getStateFromButton(button) {
    if (button.classList.contains("is-unknown")) return "unknown";
    if (button.classList.contains("is-recurrent")) return "recurrent";
    if (button.classList.contains("is-first-time")) return "first_time";
    if (button.classList.contains("is-absent")) return "absent";
    return;
  }

  updateState(row, occurrenceId, state) {
    this.channel
      .push("update_state", {
        person_id: row.getAttribute("data-id"),
        meeting_occurrence_id: occurrenceId,
        state: state
      })
      .receive("ok", resp => row.innerHTML = resp.table_row)
      .receive("error", reason => console.error("Unable to update attendant state", reason))
      .receive("timeout", _ => console.error("Networking issue..."));
  }

  addSearchListener() {
    this.searchEl.addEventListener("keydown", event => {
      if ([13, 38, 40].includes(event.keyCode)) event.preventDefault();
    });

    this.searchEl.addEventListener("keyup", event => {
      if (![13, 38, 40].includes(event.keyCode)) {
        const occurrenceId = this.tableBodyEl.getAttribute("data-occurrence-id");
        const filter = document.querySelector(".js-sidebar").getAttribute("data-filter");

        this.nameEl.value = this.searchEl.value;

        this.channel
          .push("search", {
            meeting_occurrence_id: occurrenceId,
            query: this.searchEl.value,
            filter: filter
          })
          .receive("ok", resp => {
            this.tableBodyEl.innerHTML = resp.table_body;
            this.selectRow(0);

            // needs to be rebound because it depends on the inner content
            this.bindRowHover();
          })
          .receive("error", reason => console.error("Unable to search people", reason))
          .receive("timeout", _ => console.error("Networking issue..."));
          }
    })
  }

  keyUp() {
    const row = this.getRow();
    if (row) {
      const prev = row.previousElementSibling;
      if (prev) {
        row.classList.remove("nav-focus");
        prev.classList.add("nav-focus");
      }
    } else {
      this.selectRow(this.tableBodyEl.children.length-1);
    }
  }

  keyDown() {
    const row = this.getRow();
    if (row) {
      const next = row.nextElementSibling;
      if (next) {
        row.classList.remove("nav-focus");
        next.classList.add("nav-focus");
      }
    } else {
      this.selectRow(0);
    }
  }

  keyEnter() {
    const row = this.getRow();
    const occurrenceId = this.tableBodyEl.getAttribute("data-occurrence-id");
    if (row) {
      this.toggleRow(row, occurrenceId);
    } else {
      document.getElementById("visitor_modal").classList.add("is-active");
    }
  }

  bindKeys() {
    const mousetrap = new Mousetrap(document.body);
    mousetrap.bind("up", _ => this.keyUp());
    mousetrap.bind("down", _ => this.keyDown());
    mousetrap.bind("enter", _ => this.keyEnter());
  }

  bindRowHover() {
    const rows = this.tableBodyEl.querySelectorAll(".js-person");

    for (let row of rows) {
      row.addEventListener("mouseenter", event => {
        const selectedRow = this.getRow();
        if (selectedRow) selectedRow.classList.remove("nav-focus");
        event.target.classList.add("nav-focus");
      });
    }
  }

  selectRow(index) {
    const row = this.getRow();
    if (row) row.classList.remove("nav-focus");

    const firstRow = this.tableBodyEl.children[index];
    if (firstRow) firstRow.classList.add("nav-focus");
  }

  getRow() {
    return this.tableBodyEl.querySelector(".nav-focus");
  }

  bindRowClick() {
    this.tableBodyEl.addEventListener("click", event => {
      const row = this.parentsQuerySelector(event.target, "js-person");

      const parentButton = this.parentsQuerySelector(event.target, "person-button");
      if (parentButton) {
        return this.updateState(
          row,
          this.tableBodyEl.getAttribute("data-occurrence-id"),
          this.getStateFromButton(parentButton)
        );
      }

      const occurrenceId = this.tableBodyEl.getAttribute("data-occurrence-id");
      return this.toggleRow(row, occurrenceId)
    });
  }

  parentsQuerySelector(target, className) {
    if (target == null) return null;
    if (target.classList.contains(className)) return target;

    return this.parentsQuerySelector(target.parentElement, className);
  }

  toggleRow(tr, occurrenceId) {
    const nextControl = tr
      .querySelector(".is-active")
      .parentElement
      .nextElementSibling;
    const nextButton = nextControl ?
      nextControl.querySelector(".person-button") :
      tr.querySelector(".person-button:first-child");

    return this.updateState(tr, occurrenceId, this.getStateFromButton(nextButton));
  }
}
