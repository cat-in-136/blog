window.addEventListener("load", function blogLoadHandler () {
  "use strict";
  function isInViewport(node) {
    var rect = node.getBoundingClientRect();
    return (rect.top >= 0) && (rect.left >= 0) && (rect.top <= (window.innerHeight || document.documentElement.clientHeight));
  }
  function scrollHandler () {
    var placeholders = document.querySelectorAll(".post-thumb[data-image-path]");
    for (var i = 0; i < placeholders.length; i++) {
      var placeholder = placeholders[i];
      if (isInViewport(placeholder)) {
        placeholder.style.backgroundImage = "url(\"%s\")".replace("%s", placeholder.getAttribute("data-image-path"));
        placeholder.removeAttribute("data-image-path");
      }
    }
  };
  scrollHandler();
  window.addEventListener("scroll", scrollHandler, false);
  window.removeEventListener("DOMContentLoaded", blogLoadHandler, false);
}, false);
