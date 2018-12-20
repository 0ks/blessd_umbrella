export default class PersonView {
  constructor() {
    this.help = document.querySelector(".js-import-help")
  }
  index() {
    document
      .querySelector(".js-import-help-link")
      .addEventListener("click", e => {
        e.preventDefault();
        this.help.classList.remove("is-hidden");
      })
  }
}

