document.addEventListener('DOMContentLoaded', () => {
  const messages = document.querySelectorAll(".message");

  for (let message of messages) {
    const deleteButton = message.querySelector(".delete");
    if (deleteButton) {
      deleteButton.addEventListener("click", e => {
        e.preventDefault();
        message.classList.add("is-hidden");
      });
    }
  }
});

