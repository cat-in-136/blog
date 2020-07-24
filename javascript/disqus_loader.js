(function() {
  "use strict";

  const commentBox = document.getElementById("comments");
  let disqus_loaded = false;

  function loadComments() {
    if (!disqus_loaded) {
      disqus_loaded = true;
      const s = document.createElement("script");
      s.src = 'https://catin136blog.disqus.com/embed.js';
      s.async = true;
      (document.head || document.body).appendChild(s);
    }
  }

  if ("open" in commentBox) {
    if ((location.hash === "#comments") || location.hash === "#disqus_thread") {
      commentBox.open = true;
    }
    if (commentBox.open) {
      loadComments();
    } else {
      commentBox.addEventListener("toggle", () => {
        loadComments();
      }, false);
    }
  } else {
    loadComments();
  }
})();
