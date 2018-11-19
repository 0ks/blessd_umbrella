export default class SessionView {
  static new() {
    const users = document.querySelector(".js-current-users");
    const form = document.querySelector(".js-form");

    users.querySelector(".js-manual-church").addEventListener("click", event => {
      event.preventDefault();

      form.classList.remove("is-hidden");
      users.classList.add("is-hidden");
    });

    form.querySelector(".js-choose-church").addEventListener("click", event => {
      event.preventDefault();

      users.classList.remove("is-hidden");
      form.classList.add("is-hidden");
    });
  }
}

