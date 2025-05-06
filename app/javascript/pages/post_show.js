document.addEventListener('turbo:load', pageLoaded);

function pageLoaded() {
  createHeadingAnchors();

  createCopyButtons();
}

function createHeadingAnchors() {
  const firstHeadingAnchor = document.querySelector(".blog-post-body h1 a, .blog-post-body h2 a, .blog-post-body h3 a, .blog-post-body h4 a");

  // Prevent from creating `heading anchors` multiple times because in some conditions (e.g.: on post show page, click home page, then and click home show page again), `'turbo:load'` event was triggered more than once.
  if (firstHeadingAnchor != null) {
    return;
  }

  const headingList = document.querySelectorAll('.blog-post-body h1, .blog-post-body h2, .blog-post-body h3, .blog-post-body h4');

  headingList.forEach((heading) => {
    const headingId = encodeURIComponent(heading.textContent.split(' ')[0].toLowerCase());
    heading.id = headingId;
    heading.style.cursor = 'pointer';

    heading.addEventListener('click', function (e) {
      e.preventDefault();

      window.location.hash = headingId;

      heading.scrollIntoView({ behavior: 'smooth' });
    });
  });

  if (location.href.includes('#')) {
    window.location.href = location.href; // We have to revisit to jump because the heading id(s) are just created and so the page cannot be positioned to that id.
  }
}

function createCopyButtons() {
  const firstCopyButton = document.querySelector('.blog-post-body small');

  // Prevent from creating `copy buttons` multiple times because in some conditions (e.g.: on post show page, click home page, then and click home show page again), `'turbo:load'` event was triggered more than once.
  if (firstCopyButton != null) {
    return;
  }

  const codes = document.querySelectorAll('div.highlight');

  codes.forEach((code) => {
    const copyButton = document.createElement('small');
    copyButton.innerText = 'Copy';
    copyButton.classList.add('float-end');
    copyButton.classList.add('text-light');
    copyButton.classList.add('mt-1');
    copyButton.classList.add('me-2');
    copyButton.setAttribute('data-bs-toggle', 'tooltip');
    copyButton.setAttribute('data-bs-title', "<%= t(:copy_to_clipboard) %>");
    copyButton.setAttribute('role', 'button');
    copyButton.onclick = function () {
      copyCode.call(this, code);
    };
    copyButton.onmouseout = function () {
      setTextToCopy.call(this);
    };
    code.parentNode.insertBefore(copyButton, code);
  });
}

async function copyCode(code) {
  await navigator.clipboard.writeText(code.textContent);
  this.textContent = 'Copied!';
}

function setTextToCopy() {
  this.textContent = 'Copy';
}

function togglePositionAnchor() {
  const anchor = this.lastChild;

  if (anchor.classList.contains('d-none')) {
    anchor.classList.remove('d-none');
  } else {
    anchor.classList.add('d-none');
  }
}
