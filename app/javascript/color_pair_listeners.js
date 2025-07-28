// Event Listeners for Color Pair Ranker

// Initialize sortable lists when page loads
document.addEventListener("turbo:load", function () {
  setupSortable('ugly_pairs_list', 'ugly');
  setupSortable('nice_pairs_list', 'nice');
});

// Flash message auto-hide functionality
document.addEventListener("turbo:load", () => {
  const flashMessages = ["flash-notice", "custom-message"];
  flashMessages.forEach(id => {
    const el = document.getElementById(id);
    if (el) {
      setTimeout(() => {
        el.style.transition = "opacity 1s ease";
        el.style.opacity = "0";
        setTimeout(() => el.remove(), 1000);
      }, 3000);
    }
  });
});