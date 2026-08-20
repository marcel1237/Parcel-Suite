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
let activeFilter = "all";

function normalize(value) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

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
    open.textContent = "Abrir Markdown →";
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
