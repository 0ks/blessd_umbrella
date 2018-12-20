function getModal(modalButton) {
  if (modalId = modalButton.getAttribute("data-modal-id")) {
    return document.getElementById(modalId);
  }

  return modalButton.parentElement.querySelector(".js-modal");
}

document.addEventListener('DOMContentLoaded', () => {
  const modalButtons = document.querySelectorAll(".js-modal-button");

  for (let modalButton of modalButtons) {
    const modal = getModal(modalButton);

    modalButton.addEventListener("click", e => {
      e.preventDefault()
      modal.classList.add("is-active")
    });

    const modalClosers = modal.querySelectorAll(".js-close-modal")

    for (let closer of modalClosers) {
      closer.addEventListener("click", e => {
        e.preventDefault()
        modal.classList.remove("is-active")
      });
    }
  }
});

