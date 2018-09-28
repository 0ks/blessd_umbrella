import Pikaday from "pikaday";

document.addEventListener('DOMContentLoaded', () => {
  const fields = document.querySelectorAll('.js-date');

  for (let field of fields) {
    new Pikaday({
      field: field
    });
  }
});
