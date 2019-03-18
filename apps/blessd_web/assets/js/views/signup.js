export default class SignupView {
  constructor() {
    this.timezoneSelect = document.getElementById("registration_church_timezone");
  }

  new() {
    this.timezoneSelect.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
  }
}

