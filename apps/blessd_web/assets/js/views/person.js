export default class PersonView {
  static index() {
    const help = document.querySelector(".js-import-help")
    document
      .querySelector(".js-import-help-link")
      .addEventListener("click", e => {
        e.preventDefault();
        help.classList.remove("is-hidden");
      })
  }
}

