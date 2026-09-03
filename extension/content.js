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

let currentSettings = {
  ...DEFAULT_SETTINGS,
  redirectToPlayer: localStorage.getItem('ihs_redirect_to_player') !== 'false'
};

/**
 * @param {string} [candidateUrl]
 * @returns {boolean}
 */
function handleShortsRedirection(candidateUrl) {
  if (!currentSettings.redirectToPlayer) return false;

  try {
    const url = new URL(candidateUrl || window.location.href, window.location.origin);
    const match = url.pathname.match(/^\/shorts\/([a-zA-Z0-9_-]+)/);
    if (match) {
      const videoId = match[1];
      url.pathname = '/watch';
      url.searchParams.set('v', videoId);
      window.location.replace(url.toString());
      return true;
    }
  } catch (_) {}

  return false;
}

handleShortsRedirection();

/**
 * @returns {Promise<ExtensionSettings>}
 */
async function loadSettings() {
  const storageApi = typeof chrome !== 'undefined' && chrome.storage ? chrome.storage.sync || chrome.storage.local : null;
  if (!storageApi) return DEFAULT_SETTINGS;

  return new Promise((resolve) => {
    storageApi.get(DEFAULT_SETTINGS, (items) => {
      resolve(items || DEFAULT_SETTINGS);
    });
  });
}

/**
 * @param {Element} section
 * @returns {boolean}
 */
function isShortsSection(section) {
  if (section.getAttribute('data-ihs-hidden') === 'true') return true;

  if (section.querySelector('ytd-rich-shelf-renderer[is-shorts], ytd-reel-shelf-renderer')) {
    return true;
  }

  const links = section.querySelectorAll('a[href*="/shorts"]');
  if (links.length > 0) {
    return true;
  }

  const titleElem = section.querySelector('#title, #title-text');
  if (titleElem && titleElem.textContent && titleElem.textContent.trim().toLowerCase() === 'shorts') {
    return true;
  }

  return false;
}

/**
 * @returns {void}
 */
function purgeShortsFromDOM() {
  const isSearchPage = window.location.pathname.startsWith('/results');

  if (currentSettings.hideShelves && !isSearchPage) {
    const sections = document.querySelectorAll('ytd-browse[page-subtype="home"] ytd-rich-section-renderer:not([data-ihs-hidden="true"]), ytd-browse[page-subtype="subscriptions"] ytd-rich-section-renderer:not([data-ihs-hidden="true"])');
    for (const section of sections) {
      if (isShortsSection(section)) {
        section.setAttribute('data-ihs-hidden', 'true');
        section.style.setProperty('display', 'none', 'important');
      }
    }

    const reelShelves = document.querySelectorAll('ytd-browse ytd-reel-shelf-renderer:not([data-ihs-hidden="true"]), ytd-watch-flexy ytd-reel-shelf-renderer:not([data-ihs-hidden="true"])');
    for (const shelf of reelShelves) {
      shelf.setAttribute('data-ihs-hidden', 'true');
      shelf.style.setProperty('display', 'none', 'important');
    }

    const items = document.querySelectorAll('ytd-browse[page-subtype="home"] ytd-rich-item-renderer:not([data-ihs-hidden="true"])');
    for (const item of items) {
      if (item.querySelector('a[href^="/shorts/"]')) {
        item.setAttribute('data-ihs-hidden', 'true');
        item.style.setProperty('display', 'none', 'important');
      }
    }
  }

  if (currentSettings.hideSidebar) {
    const sidebars = document.querySelectorAll('ytd-guide-entry-renderer:not([data-ihs-hidden="true"]), ytd-mini-guide-entry-renderer:not([data-ihs-hidden="true"])');
    for (const entry of sidebars) {
      const link = entry.querySelector('a[href^="/shorts"], a[title="Shorts"]');
      if (link || entry.getAttribute('aria-label') === 'Shorts') {
        entry.setAttribute('data-ihs-hidden', 'true');
        entry.style.setProperty('display', 'none', 'important');
      }
    }
  }
}

let scheduledFrame = null;
/**
 * @returns {void}
 */
function requestPurge() {
  if (scheduledFrame) return;
  scheduledFrame = requestAnimationFrame(() => {
    scheduledFrame = null;
    purgeShortsFromDOM();
  });
}

/**
 * @returns {void}
 */
function setupLinkInterceptor() {
  document.addEventListener('click', (event) => {
    if (!currentSettings.redirectToPlayer) return;

    const target = event.target;
    const link = target instanceof Element ? target.closest('a[href*="/shorts/"]') : null;
    if (link && link.getAttribute('href')) {
      const href = link.getAttribute('href');
      const match = href.match(/\/shorts\/([a-zA-Z0-9_-]+)/);
      if (match) {
        event.preventDefault();
        event.stopPropagation();
        const videoId = match[1];
        const targetUrl = `/watch?v=${videoId}`;
        window.location.href = targetUrl;
      }
    }
  }, true);
}

/**
 * @returns {void}
 */
function init() {
  loadSettings().then((settings) => {
    currentSettings = settings;
    localStorage.setItem('ihs_redirect_to_player', String(settings.redirectToPlayer));
    handleShortsRedirection();
    purgeShortsFromDOM();
  });

  setupLinkInterceptor();

  const observer = new MutationObserver((mutations) => {
    let hasRelevantNodes = false;
    for (const mutation of mutations) {
      if (mutation.addedNodes.length > 0) {
        hasRelevantNodes = true;
        break;
      }
    }
    if (hasRelevantNodes) {
      requestPurge();
    }
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });

  window.addEventListener('yt-navigate-start', (event) => {
    const url = event.detail?.url;
    if (url) {
      handleShortsRedirection(url);
    }
  });

  window.addEventListener('yt-navigate-finish', () => {
    handleShortsRedirection();
    requestPurge();
  });

  window.addEventListener('popstate', () => {
    handleShortsRedirection();
    requestPurge();
  });

  window.addEventListener('yt-page-data-updated', requestPurge);
  window.addEventListener('load', requestPurge);

  const storageApi = typeof chrome !== 'undefined' && chrome.storage ? chrome.storage.onChanged : null;
  if (storageApi) {
    storageApi.addListener((changes) => {
      if (changes.hideShelves) {
        currentSettings.hideShelves = Boolean(changes.hideShelves.newValue);
      }
      if (changes.hideSidebar) {
        currentSettings.hideSidebar = Boolean(changes.hideSidebar.newValue);
      }
      if (changes.redirectToPlayer) {
        currentSettings.redirectToPlayer = Boolean(changes.redirectToPlayer.newValue);
        localStorage.setItem('ihs_redirect_to_player', String(currentSettings.redirectToPlayer));
      }
      purgeShortsFromDOM();
    });
  }
}

init();
