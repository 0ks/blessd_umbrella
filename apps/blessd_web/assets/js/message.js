document.addEventListener('DOMContentLoaded', () => {
  const messages = document.querySelectorAll(".message");

  for (let message of messages) {
    message.querySelector(".delete").addEventListener("click", e => {
      e.preventDefault();
      message.classList.add("is-hidden");
    })
  }
});

