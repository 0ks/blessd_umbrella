export default class DashboardView {
  constructor() {
    this.missedMeetingForm = document.querySelector(".js-missed-meeting-form");
    this.missedMeetingSelect = document.querySelector(".js-missed-meeting-select");

    this.todayMeetingSelect = document.querySelector(".js-today-meeting-select");
    this.todayMeetingOccurrences = document.querySelectorAll(".js-today-meeting-occurrence");
  }

  index() {
    this.listenMissedMeetingSelect();
    this.listenTodayMeetingSelect();
    this.showSelectedMeeting();
  }

  listenMissedMeetingSelect() {
    this.missedMeetingSelect.addEventListener("change", event => {
      this.missedMeetingForm.submit();
    })
  }

  listenTodayMeetingSelect() {
    this.todayMeetingSelect.addEventListener("change", event => {
      this.showSelectedMeeting();
    })
  }

  showSelectedMeeting() {
    for (let occurrence of this.todayMeetingOccurrences) {
      if (occurrence.getAttribute("data-id") == this.todayMeetingSelect.value) {
        occurrence.classList.remove("is-hidden");
      } else {
        occurrence.classList.add("is-hidden");
      }
    }
  }
}

