document.addEventListener('DOMContentLoaded', () => {
  const fileInputs = document.querySelectorAll(".file-input");

  for (let fileInput of fileInputs) {
    const fileName = fileInput.parentElement.querySelector(".file-name");

    fileInput.addEventListener("change", _ => {
      fileName.innerHTML = Array.from(fileInput.files)
        .map(file => file.name)
        .join(", ");
    });
  }
});
