import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "form", "submitButton", "spinner", "successMessage", "errorMessage"]

  connect() {
    // Initialize the controller
    this.emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
  }

  validateEmail(event) {
    const emailInput = event.target;
    const errorElement = document.getElementById("email-error");

    if (!emailInput.value) {
      emailInput.classList.add("is-invalid");
      errorElement.textContent = "Please enter an email address";
      return false;
    } else if (!this.emailRegex.test(emailInput.value)) {
      emailInput.classList.add("is-invalid");
      errorElement.textContent = "Please enter a valid email address";
      return false;
    } else {
      emailInput.classList.remove("is-invalid");
      emailInput.classList.add("is-valid");
      errorElement.textContent = "";
      return true;
    }
  }

  submit(event) {
    event.preventDefault();

    const form = event.target.closest("form");
    const emailInput = form.querySelector("#subscription_email");

    if (!this.validateEmail({ target: emailInput })) {
      return;
    }

    // Show spinner and disable button
    const submitButton = form.querySelector("button[type='submit']");
    const buttonText = submitButton.querySelector(".button-text");
    const spinner = submitButton.querySelector(".spinner-border");

    buttonText.classList.add("d-none");
    spinner.classList.remove("d-none");
    submitButton.disabled = true;

    // Hide any existing messages
    const successMessage = form.querySelector("#subscription-success");
    const errorMessage = form.querySelector("#subscription-error");
    successMessage.classList.add("d-none");
    errorMessage.classList.add("d-none");

    const formData = new FormData(form);

    // Submit form with fetch API
    fetch(form.action, {
      method: "POST",
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData,
      credentials: "same-origin"
    })
      .then(response => {
        return response.json().then(data => {
          return { status: response.status, data };
        });
      })
      .then(({ status, data }) => {
        if (status === 201) {
          // Success
          this.showSuccess(data.message);
          form.reset();
          emailInput.classList.remove("is-valid");
        } else {
          // Error
          this.showError(data.errors);
        }
      })
      .catch(error => {
        this.showError("An error occurred. Please try again later.");
        console.error("Submission error:", error);
      })
      .finally(() => {
        // Hide spinner and re-enable button
        buttonText.classList.remove("d-none");
        spinner.classList.add("d-none");
        submitButton.disabled = false;
      });
  }

  showSuccess(message) {
    const successMessage = document.getElementById("subscription-success");
    successMessage.textContent = message;
    successMessage.classList.remove("d-none");
  }

  showError(errors) {
    const errorMessage = document.getElementById("subscription-error");
    if (Array.isArray(errors)) {
      errorMessage.textContent = errors.join(". ");
    } else {
      errorMessage.textContent = errors;
    }
    errorMessage.classList.remove("d-none");
  }
}
