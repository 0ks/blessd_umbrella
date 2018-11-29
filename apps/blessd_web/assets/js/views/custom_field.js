export default class CustomFieldView {
  static edit() {
    document.getElementById("field_type").addEventListener("change", CustomFieldView.showWarning);
    document.querySelector(".js-validations").addEventListener("change", CustomFieldView.showWarning);
  }

  static showWarning() {
    document.querySelector(".js-warning").classList.remove("is-hidden");
    document.querySelector(".js-warning-submit").classList.remove("is-hidden");
    document.querySelector(".js-normal-submit").classList.add("is-hidden");
  }
}

