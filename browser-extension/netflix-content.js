function setAdded(btn) {
  btn.textContent = '✓ Added (click to remove)';
  btn.style.cssText = `
    display: inline-flex; align-items: center; gap: 8px;
    padding: 8px 18px;
    border-radius: 8px;
    background: #2ecc71;
    color: #fff;
    font-family: 'Syne', sans-serif;
    font-weight: 700;
    font-size: 13px;
    border: none;
    cursor: pointer;
    letter-spacing: 0.3px;
  `;
  btn.disabled = false;
  btn.dataset.added = "1";
}

function setNotAdded(btn) {
  btn.textContent = 'Add to Nodisaar';
  btn.style.cssText = `
    display: inline-flex; align-items: center; gap: 8px;
    padding: 8px 18px;
    border-radius: 8px;
    background: linear-gradient(135deg, #e50914, #00a8e1);
    color: #fff;
    font-family: 'Syne', sans-serif;
    font-weight: 700;
    font-size: 13px;
    text-decoration: none;
    letter-spacing: 0.3px;
    border: none;
    cursor: pointer;
    transition: opacity 0.15s, transform 0.15s;
  `;
  btn.dataset.added = "0";
}

function injectAddButtons() {
  const rows = document.querySelectorAll('li.retableRow[data-uia="activity-row"]');
  rows.forEach(row => {
    if (row.dataset.nodisaarInjected) return;
    row.dataset.nodisaarInjected = "1";

    const reportCol = row.querySelector('.col.report');
    if (!reportCol) return;

    const titleAnchor = row.querySelector('.col.title a');
    if (!titleAnchor) return;

    const title = titleAnchor.textContent.trim();
    const href = titleAnchor.getAttribute('href');

    reportCol.innerHTML = '';
    const btn = document.createElement('button');
    btn.className = 'nodisaar-btn';
     btn.style.cssText = `
      display: inline-flex; align-items: center; gap: 8px;
      padding: 8px 18px;
      border-radius: 8px;
      background: linear-gradient(135deg, #e50914, #00a8e1);
      color: #fff;
      font-family: 'Syne', sans-serif;
      font-weight: 700;
      font-size: 13px;
      text-decoration: none;
      letter-spacing: 0.3px;
      border: none;
      cursor: pointer;
      transition: opacity 0.15s, transform 0.15s;
    `;

    btn.addEventListener('click', () => {
      chrome.storage.local.get(['netflix'], ({ netflix = [] }) => {
        const exists = netflix.some(i => i.href === href);
        if (!exists) {
          netflix.push({ title, href, source: 'netflix', addedAt: Date.now() });
          chrome.storage.local.set({ netflix }, () => setAdded(btn));
        } else {
          const updated = netflix.filter(i => i.href !== href);
          chrome.storage.local.set({ netflix: updated }, () => setNotAdded(btn));
        }
      });
    });

    // Initial state
    chrome.storage.local.get(['netflix'], ({ netflix = [] }) => {
      if (netflix.some(i => i.href === href)) {
        setAdded(btn);
      } else {
        setNotAdded(btn);
      }
    });

    reportCol.appendChild(btn);
  });
}

const observer = new MutationObserver(injectAddButtons);
observer.observe(document.body, { childList: true, subtree: true });
injectAddButtons();