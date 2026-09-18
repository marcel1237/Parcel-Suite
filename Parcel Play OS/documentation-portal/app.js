const portalData = window.PLAYOS_PORTAL;
if (!portalData) {
  throw new Error("Catálogo do portal ausente. Execute: make -C documentation-portal generate");
}
const documents = portalData.documents;
const statTargets = {
  sources: document.querySelector("#stat-sources"),
  documents: document.querySelector("#stat-documents"),
  knowledge: document.querySelector("#stat-knowledge"),
  qa: document.querySelector("#stat-qa")
};
Object.entries(statTargets).forEach(([key, target]) => {
  target.textContent = portalData.stats[key] ?? "—";
});

const grid = document.querySelector("#document-grid");
const search = document.querySelector("#search");
const count = document.querySelector("#result-count");
const empty = document.querySelector("#empty-state");
const filters = [...document.querySelectorAll(".filter")];
const markdownViewer = document.querySelector("#markdown-viewer");
const markdownStatus = document.querySelector("#markdown-status");
const markdownContent = document.querySelector("#markdown-content");
const markdownClose = document.querySelector("#markdown-close");
const markdownFullscreen = document.querySelector("#markdown-fullscreen");
let activeFilter = "all";

function normalize(value) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function escapeHtml(value) {
  return value.replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#039;"
  }[character]));
}

function safeUrl(value, baseUrl) {
  try {
    const url = new URL(value, baseUrl);
    if (["http:", "https:", "mailto:"].includes(url.protocol)) {
      return url.href;
    }
    if (url.protocol === window.location.protocol && url.origin === window.location.origin) {
      return url.href;
    }
  } catch {
    return null;
  }
  return null;
}

function inlineMarkdown(value, baseUrl) {
  let html = escapeHtml(value);
  html = html.replace(/`([^`]+)`/g, "<code>$1</code>");
  html = html.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  html = html.replace(/__([^_]+)__/g, "<strong>$1</strong>");
  html = html.replace(/(?<!\*)\*([^*]+)\*(?!\*)/g, "<em>$1</em>");
  html = html.replace(/(?<!_)_([^_]+)_(?!_)/g, "<em>$1</em>");
  html = html.replace(/\[([^\]]+)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g, (match, label, target) => {
    const href = safeUrl(target, baseUrl);
    return href ? `<a href="${escapeHtml(href)}">${label}</a>` : label;
  });
  return html;
}

function markdownToHtml(markdown, sourceUrl) {
  const lines = markdown.replace(/\r\n?/g, "\n").split("\n");
  const output = [];
  let paragraph = [];
  let listType = null;
  let code = null;
  let table = null;

  const flushParagraph = () => {
    if (paragraph.length) {
      output.push(`<p>${inlineMarkdown(paragraph.join(" "), sourceUrl)}</p>`);
      paragraph = [];
    }
  };
  const closeList = () => {
    if (listType) {
      output.push(`</${listType}>`);
      listType = null;
    }
  };
  const closeTable = () => {
    if (table) {
      output.push("</tbody></table>");
      table = null;
    }
  };

  lines.forEach((line, index) => {
    if (code) {
      if (line.trim().startsWith("```")) {
        output.push(`</code></pre>`);
        code = null;
      } else {
        output.push(`${escapeHtml(line)}\n`);
      }
      return;
    }
    if (line.trim().startsWith("```")) {
      flushParagraph();
      closeList();
      closeTable();
      const language = line.trim().slice(3).trim();
      output.push(`<pre><code class="language-${escapeHtml(language)}">`);
      code = language || "plain";
      return;
    }
    if (/^\s*\|.*\|\s*$/.test(line) && index + 1 < lines.length && /^\s*\|?[\s:-]+(?:\|[\s:-]+)+\|?\s*$/.test(lines[index + 1])) {
      flushParagraph();
      closeList();
      closeTable();
      const cells = line.trim().replace(/^\|/, "").replace(/\|$/, "").split("|");
      output.push(`<table><thead><tr>${cells.map((cell) => `<th>${inlineMarkdown(cell.trim(), sourceUrl)}</th>`).join("")}</tr></thead><tbody>`);
      table = "open";
      return;
    }
    if (table && /^\s*\|.*\|\s*$/.test(line)) {
      const cells = line.trim().replace(/^\|/, "").replace(/\|$/, "").split("|");
      output.push(`<tr>${cells.map((cell) => `<td>${inlineMarkdown(cell.trim(), sourceUrl)}</td>`).join("")}</tr>`);
      return;
    }
    closeTable();
    const heading = line.match(/^\s{0,3}(#{1,6})\s+(.+?)\s*#*\s*$/);
    if (heading) {
      flushParagraph();
      closeList();
      const level = heading[1].length;
      output.push(`<h${level}>${inlineMarkdown(heading[2], sourceUrl)}</h${level}>`);
      return;
    }
    if (/^\s*([-*_])(?:\s*\1){2,}\s*$/.test(line)) {
      flushParagraph();
      closeList();
      output.push("<hr>");
      return;
    }
    const quote = line.match(/^\s*>\s?(.*)$/);
    if (quote) {
      flushParagraph();
      closeList();
      output.push(`<blockquote>${inlineMarkdown(quote[1], sourceUrl)}</blockquote>`);
      return;
    }
    const item = line.match(/^\s*([-*+]|\d+\.)\s+(.*)$/);
    if (item) {
      flushParagraph();
      const requestedType = /^\d/.test(item[1]) ? "ol" : "ul";
      if (listType !== requestedType) {
        closeList();
        listType = requestedType;
        output.push(`<${listType}>`);
      }
      const checkbox = item[2].match(/^\[([ xX])\]\s+(.*)$/);
      if (checkbox) {
        output.push(`<li class="task-item"><input type="checkbox" disabled${checkbox[1].toLowerCase() === "x" ? " checked" : ""}> ${inlineMarkdown(checkbox[2], sourceUrl)}</li>`);
      } else {
        output.push(`<li>${inlineMarkdown(item[2], sourceUrl)}</li>`);
      }
      return;
    }
    if (!line.trim()) {
      flushParagraph();
      closeList();
      closeTable();
      return;
    }
    closeList();
    paragraph.push(line.trim());
  });

  flushParagraph();
  closeList();
  closeTable();
  if (code) {
    output.push("</code></pre>");
  }
  return output.join("\n");
}

function showMarkdownStatus(message, error = false) {
  markdownStatus.hidden = false;
  markdownStatus.classList.toggle("error", error);
  markdownStatus.textContent = message;
}

async function openMarkdownViewer(url) {
  markdownContent.replaceChildren();
  markdownStatus.hidden = true;
  markdownViewer.showModal();
  try {
    const response = await fetch(url.href, { credentials: "same-origin" });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    const markdown = await response.text();
    markdownContent.innerHTML = markdownToHtml(markdown, url.href);
    markdownContent.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", handleMarkdownLink);
    });
  } catch (error) {
    const localFile = window.location.protocol === "file:";
    showMarkdownStatus(
      localFile
        ? "O navegador bloqueou a leitura automática de arquivos locais por segurança. Sirva o portal com `python3 -m http.server` na raiz do projeto e abra http://localhost:8000/documentation-portal/."
        : `Não foi possível carregar este Markdown (${error.message}). Abra o arquivo original para investigar o caminho.`,
      true
    );
    const fallback = document.createElement("a");
    fallback.href = url.href;
    fallback.textContent = "Abrir arquivo original";
    fallback.className = "markdown-fallback";
    markdownContent.append(fallback);
  }
}

function handleMarkdownLink(event) {
  const rawHref = event.currentTarget.getAttribute("href");
  if (!rawHref || rawHref.startsWith("#")) {
    return;
  }
  const url = new URL(rawHref, window.location.href);
  if (url.origin === window.location.origin && url.pathname.toLowerCase().endsWith(".md")) {
    event.preventDefault();
    openMarkdownViewer(url);
  }
}

document.addEventListener("click", (event) => {
  const link = event.target.closest("a[href]");
  if (!link || link.closest("#markdown-viewer")) {
    return;
  }
  const url = new URL(link.href, window.location.href);
  if (url.origin === window.location.origin && url.pathname.toLowerCase().endsWith(".md")) {
    event.preventDefault();
    openMarkdownViewer(url);
  }
});

markdownClose.addEventListener("click", () => markdownViewer.close());
markdownFullscreen.addEventListener("click", async () => {
  try {
    if (document.fullscreenElement) {
      await document.exitFullscreen();
    } else if (markdownViewer.requestFullscreen) {
      await markdownViewer.requestFullscreen();
    } else {
      markdownViewer.classList.toggle("fullscreen-fallback");
    }
  } catch (error) {
    markdownViewer.classList.toggle("fullscreen-fallback");
    showMarkdownStatus(`Tela cheia indisponível neste navegador: ${error.message}`, true);
  }
});
document.addEventListener("fullscreenchange", () => {
  const active = document.fullscreenElement === markdownViewer;
  markdownFullscreen.textContent = active ? "Sair da tela cheia ⛶" : "Tela cheia ⛶";
  markdownFullscreen.setAttribute("aria-label", active ? "Sair da tela cheia" : "Ativar tela cheia");
});
markdownViewer.addEventListener("click", (event) => {
  if (event.target === markdownViewer) {
    markdownViewer.close();
  }
});

function render() {
  const query = normalize(search.value.trim());
  const visible = documents.filter((item) => {
    const matchesFilter = activeFilter === "all" || item.area === activeFilter;
    const haystack = normalize(`${item.title} ${item.description} ${item.tags} ${item.status}`);
    return matchesFilter && (!query || haystack.includes(query));
  });

  grid.replaceChildren(...visible.map((item) => {
    const card = document.createElement("a");
    card.className = "doc-card";
    card.href = item.href;
    const meta = document.createElement("div");
    meta.className = "doc-meta";
    const status = document.createElement("span");
    status.textContent = item.status;
    const priority = document.createElement("span");
    priority.className = "priority";
    priority.textContent = item.priority;
    meta.append(status, priority);
    const title = document.createElement("h3");
    title.textContent = item.title;
    const description = document.createElement("p");
    description.textContent = item.description;
    const open = document.createElement("span");
    open.className = "doc-open";
    open.textContent = "Visualizar Markdown →";
    card.append(meta, title, description, open);
    return card;
  }));

  count.textContent = `${visible.length} ${visible.length === 1 ? "documento encontrado" : "documentos encontrados"}`;
  empty.hidden = visible.length !== 0;
}

search.addEventListener("input", render);
filters.forEach((button) => button.addEventListener("click", () => {
  activeFilter = button.dataset.filter;
  filters.forEach((candidate) => {
    const selected = candidate === button;
    candidate.classList.toggle("active", selected);
    candidate.setAttribute("aria-pressed", String(selected));
  });
  render();
}));

filters.forEach((button) => button.setAttribute("aria-pressed", String(button.classList.contains("active"))));
render();
