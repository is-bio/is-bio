document.addEventListener('turbo:load', pageLoaded);

function pageLoaded() {
  createHeadingAnchors();

  createCopyButtons();
}

function createHeadingAnchors() {
  const headingAnchors = document.querySelectorAll("h1 a, h2 a, h3 a, h4 a, h5 a, h6 a");

  // Protect from creating `headingAnchor` multi-times because in some conditions `'turbo:load'` event was trigger more than once.
  if (headingAnchors.length > 1) {
    return;
  }

  const headingList = document.querySelectorAll('h1, h2, h3, h4, h5, h6');

  headingList.forEach((heading) => {
    if (heading.id) {
      return;
    }

    const headingId = encodeURIComponent(heading.textContent.split(' ')[0].toLowerCase());
    heading.id = headingId;

    const anchor = document.createElement('a');
    anchor.href = `#${headingId}`;
    anchor.classList.add('d-none');
    anchor.classList.add('text-muted');
    anchor.text = ' #';
    heading.insertAdjacentElement('beforeend', anchor);

    heading.addEventListener('mouseover', togglePositionAnchor);
    heading.addEventListener('mouseout', togglePositionAnchor);
  });

  if (location.href.includes('#')) {
    window.location.href = location.href; // We have to revisit to jump because the heading id(s) are just created and so the page cannot be positioned to that id.
  }
}

function createCopyButtons() {
  const small = document.querySelector('small');

  // Protect from creating `small` multi-times because in some conditions `'turbo:load'` event was trigger more than once.
  if (small != null && !small.classList.contains('copyright')) {
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
