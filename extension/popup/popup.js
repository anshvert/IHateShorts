/**
 * @typedef {Object} ExtensionSettings
 * @property {boolean} hideShelves
 * @property {boolean} hideSidebar
 * @property {boolean} redirectToPlayer
 */

const DEFAULT_SETTINGS = {
  hideShelves: true,
  hideSidebar: true,
  redirectToPlayer: true
};

/**
 * @returns {typeof chrome.storage.sync | typeof chrome.storage.local | null}
 */
function getStorage() {
  if (typeof chrome !== 'undefined' && chrome.storage) {
    return chrome.storage.sync || chrome.storage.local;
  }
  return null;
}

/**
 * @param {ExtensionSettings} settings
 * @returns {void}
 */
function applySettingsToUI(settings) {
  const shelvesInput = document.getElementById('toggle-shelves');
  const sidebarInput = document.getElementById('toggle-sidebar');
  const redirectInput = document.getElementById('toggle-redirect');

  if (shelvesInput) {
    shelvesInput.checked = Boolean(settings.hideShelves);
  }
  if (sidebarInput) {
    sidebarInput.checked = Boolean(settings.hideSidebar);
  }
  if (redirectInput) {
    redirectInput.checked = Boolean(settings.redirectToPlayer);
  }
}

/**
 * @param {Partial<ExtensionSettings>} update
 * @returns {void}
 */
function saveSetting(update) {
  const storage = getStorage();
  if (storage) {
    storage.set(update);
  }
}

/**
 * @returns {void}
 */
function setupEventListeners() {
  const shelvesInput = document.getElementById('toggle-shelves');
  const sidebarInput = document.getElementById('toggle-sidebar');
  const redirectInput = document.getElementById('toggle-redirect');

  if (shelvesInput) {
    shelvesInput.addEventListener('change', (e) => {
      saveSetting({ hideShelves: e.target.checked });
    });
  }

  if (sidebarInput) {
    sidebarInput.addEventListener('change', (e) => {
      saveSetting({ hideSidebar: e.target.checked });
    });
  }

  if (redirectInput) {
    redirectInput.addEventListener('change', (e) => {
      saveSetting({ redirectToPlayer: e.target.checked });
    });
  }
}

/**
 * @returns {void}
 */
function init() {
  const storage = getStorage();
  if (storage) {
    storage.get(DEFAULT_SETTINGS, (items) => {
      applySettingsToUI(items || DEFAULT_SETTINGS);
    });
  } else {
    applySettingsToUI(DEFAULT_SETTINGS);
  }

  setupEventListeners();
}

document.addEventListener('DOMContentLoaded', init);
