export default class SessionView {
  constructor() {
    this.users = document.querySelector(".js-current-users");
    this.form = document.querySelector(".js-form");
  }

  new() {
    this.users.querySelector(".js-manual-church").addEventListener("click", event => {
      event.preventDefault();

      this.form.classList.remove("is-hidden");
      this.users.classList.add("is-hidden");
    });

    this.form.querySelector(".js-choose-church").addEventListener("click", event => {
      event.preventDefault();

      this.users.classList.remove("is-hidden");
      this.form.classList.add("is-hidden");
    });
  }
}

