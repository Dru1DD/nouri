// Contact address shown on every page. Change it here only.
const SUPPORT_EMAIL = "olexandrandrichuk@gmail.com";

const LANGS = ["en", "ru", "uk", "pl"];

function pickLanguage() {
  const fromQuery = new URLSearchParams(location.search).get("lang");
  if (LANGS.includes(fromQuery)) return fromQuery;
  try {
    const saved = localStorage.getItem("lang");
    if (LANGS.includes(saved)) return saved;
  } catch {}
  for (const tag of navigator.languages || [navigator.language || "en"]) {
    const base = tag.toLowerCase().split("-")[0];
    if (LANGS.includes(base)) return base;
  }
  return "en";
}

function applyLanguage(lang) {
  document.documentElement.lang = lang;
  for (const el of document.querySelectorAll("[data-lang]")) {
    el.hidden = el.dataset.lang !== lang;
    if (!el.hidden && el.dataset.title) document.title = el.dataset.title;
  }
  for (const btn of document.querySelectorAll("[data-set-lang]")) {
    btn.setAttribute("aria-pressed", String(btn.dataset.setLang === lang));
  }
  // Keep the chosen language when following internal links.
  for (const a of document.querySelectorAll("a[data-internal]")) {
    const url = new URL(a.getAttribute("href"), location.href);
    url.searchParams.set("lang", lang);
    a.href = url.pathname.split("/").pop() + url.search;
  }
}

document.addEventListener("DOMContentLoaded", () => {
  for (const a of document.querySelectorAll("a.email")) {
    a.href = "mailto:" + SUPPORT_EMAIL + "?subject=Nouri";
    a.textContent = SUPPORT_EMAIL;
  }
  for (const btn of document.querySelectorAll("[data-set-lang]")) {
    btn.addEventListener("click", () => {
      try { localStorage.setItem("lang", btn.dataset.setLang); } catch {}
      applyLanguage(btn.dataset.setLang);
    });
  }
  applyLanguage(pickLanguage());
});
