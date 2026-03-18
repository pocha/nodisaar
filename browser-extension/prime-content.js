function setAdded(btn) {
  btn.textContent = '✓ Added (click to remove)';
  btn.style.background = '#2ecc71';
  btn.style.color = '#fff';
  btn.dataset.added = "1";
}

function setNotAdded(btn) {
  btn.textContent = 'Add to Nodisaar favourites';
  btn.style.background = '#00a8e1';
  btn.style.color = '#fff';
  btn.dataset.added = "0";
}

function injectAddButtons() {
  const rows = document.querySelectorAll('li.avarm3[data-automation-id^="wh-item-"]');
  rows.forEach(row => {
    if (row.dataset.nodisaarInjected) return;
    row.dataset.nodisaarInjected = "1";

    const titleAnchor = row.querySelector('a._1NNx6V, a[href*="/detail/"]');
    const deleteForm  = row.querySelector('form[data-automation-id^="wh-delete-"]');
    if (!titleAnchor || !deleteForm) return;

    const title = titleAnchor.textContent.trim();
    const href  = titleAnchor.getAttribute('href');

    const btn = document.createElement('button');
    btn.type = 'button';
    btn.style.cssText = `
      color: #fff; border: none;
      padding: 6px 12px; border-radius: 4px; cursor: pointer;
      font-size: 13px; font-family: inherit; margin-top: 6px;
    `;

    btn.addEventListener('click', () => {
      chrome.storage.local.get(['prime'], ({ prime = [] }) => {
        const exists = prime.some(i => i.href === href);
        if (!exists) {
          prime.push({ title, href, source: 'prime', addedAt: Date.now() });
          chrome.storage.local.set({ prime }, () => setAdded(btn));
        } else {
          const updated = prime.filter(i => i.href !== href);
          chrome.storage.local.set({ prime: updated }, () => setNotAdded(btn));
        }
      });
    });

    // Initial state
    chrome.storage.local.get(['prime'], ({ prime = [] }) => {
      if (prime.some(i => i.href === href)) {
        setAdded(btn);
      } else {
        setNotAdded(btn);
      }
    });

    deleteForm.parentNode.insertBefore(btn, deleteForm);
  });
}

const observer = new MutationObserver(injectAddButtons);
observer.observe(document.body, { childList: true, subtree: true });
injectAddButtons();