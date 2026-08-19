const documents = [
  { title: "FreeBSD 15.1: identidade e capacidades", area: "freebsd", status: "verificado", priority: "P0", description: "Baseline, commit, dimensão e capacidades confirmadas na árvore completa.", href: "../supervised_learning/knowledge/freebsd/identity-capabilities.md", tags: "freebsd 15.1 source kernel capabilities" },
  { title: "Mapa técnico de sys/kern", area: "freebsd", status: "verificado", priority: "P0", description: "Famílias, dependências, símbolos e limites de portabilidade do coração do FreeBSD.", href: "../supervised_learning/knowledge/freebsd/sys-kern-map.md", tags: "sys/kern scheduler locks jail vfs newbus" },
  { title: "Referência de subsistemas FreeBSD", area: "freebsd", status: "novo", priority: "P0", description: "Caminhos de código, conceitos e regra PlayOS para cada domínio do kernel.", href: "../supervised_learning/knowledge/freebsd/subsystem-reference.md", tags: "source paths subsystems uma geom cam bhyve" },
  { title: "Segurança e isolamento", area: "freebsd", status: "verificado", priority: "P0", description: "Jails, VNET, Capsicum, RACCT/RCTL, MAC e sua tradução controlada para Linux.", href: "../supervised_learning/knowledge/freebsd/security-isolation.md", tags: "jails capsicum vnet rctl mac seccomp landlock" },
  { title: "I/O, rede e virtualização", area: "freebsd", status: "verificado", priority: "P1", description: "sendfile, kTLS, ZFS, bhyve, Linuxulator e os limites das evidências atuais.", href: "../supervised_learning/knowledge/freebsd/io-network-virtualization.md", tags: "network ktls sendfile zfs bhyve linuxulator" },
  { title: "Inventário FreeBSD 15.1-p2", area: "freebsd", status: "fonte", priority: "P0", description: "Inventário extenso do kernel, userland, boot, instalador, segurança e testes.", href: "../patch-linux7.1.8-FreeBSD/INVENTARIO_FREEBSD_15.1_P2.md", tags: "inventory drivers filesystem boot installer tests" },
  { title: "OpenBSD e NetBSD no PlayOS", area: "bsd", status: "comparativo", priority: "P2", description: "O papel correto dos outros BSDs e a assimetria atual das evidências.", href: "../supervised_learning/knowledge/bsd-family/openbsd-netbsd.md", tags: "openbsd netbsd freebsd family pf rump" },
  { title: "Comparação OpenBSD × FreeBSD", area: "bsd", status: "fonte", priority: "P1", description: "Filosofia, kernel, segurança, rede, armazenamento, virtualização e hardware.", href: "../COMPARACAO_OPENBSD_FREEBSD.md", tags: "openbsd freebsd comparison security pf zfs" },
  { title: "Glossário BSD/Linux/PlayOS", area: "bsd", status: "novo", priority: "P1", description: "Vocabulário técnico para respostas consistentes e sem falsos equivalentes.", href: "../supervised_learning/knowledge/bsd-family/glossary.md", tags: "glossary definitions jail uma mbuf rcu lsm" },
  { title: "Mapeamento FreeBSD–Linux", area: "mapping", status: "decisão", priority: "P0", description: "Matriz operacional de mecanismos, equivalentes e ações permitidas.", href: "../supervised_learning/knowledge/mappings/freebsd-linux.md", tags: "mapping linux freebsd porting equivalents" },
  { title: "Auditoria de portabilidade sys/kern", area: "mapping", status: "fonte", priority: "P0", description: "Avaliação por família: usar, comparar, reimplementar, extrair ou rejeitar.", href: "../PORTABILIDADE_FREEBSD15_SYS_KERN_PARA_UBUNTU.md", tags: "portability ubuntu sys/kern audit" },
  { title: "Integração sys/kern no Ubuntu", area: "mapping", status: "decisão", priority: "P0", description: "Arquitetura em camadas e veredito contra cópia direta de subsistemas.", href: "../INTEGRACAO_SYS_KERN_FREEBSD_NO_UBUNTU_2026-08-18.md", tags: "ubuntu integration layers sys/kern" },
  { title: "Linux 7.1.8 → FreeBSD", area: "mapping", status: "experimental", priority: "P1", description: "Análise invertida de concorrência, scheduler, PSI, NTSYNC, I/O e tracing.", href: "../patch-linux7.1.8-FreeBSD/ANALISE_COMPARATIVA.md", tags: "reverse port linux freebsd ntsync psi io_uring" },
  { title: "Arquitetura PlayOS Linux + FreeBSD", area: "playos", status: "decisão", priority: "P0", description: "Fronteiras do produto, kernels separados e contratos userspace comuns.", href: "../PLAYOS_ARQUITETURA_LINUX_FREEBSD_2026-08-18.md", tags: "playos architecture product linux freebsd" },
  { title: "PlayOS unificado", area: "playos", status: "proposta", priority: "P1", description: "Host Linux, FreeBSD Core virtualizado, comunicação, dados e resiliência.", href: "../PLAYOS_UNIFICADO_UBUNTU_FREEBSD_2026-08-18.md", tags: "kvm guest core unified architecture" },
  { title: "Estado real do PlayOS", area: "playos", status: "verificado", priority: "P0", description: "Decisões vigentes e separação entre proposta, build, boot e produção.", href: "../supervised_learning/knowledge/playos/decisions-status.md", tags: "status decisions reality production" },
  { title: "Roadmap de conhecimento BSD", area: "playos", status: "novo", priority: "P0", description: "Boot FreeBSD, dossiês sys/kern, benchmarks, família BSD e expansão QA.", href: "../supervised_learning/ROADMAP_BSD_KNOWLEDGE.md", tags: "roadmap priorities qemu benchmarks dataset" },
  { title: "Build Ubuntu Noble Generic", area: "evidence", status: "compilado", priority: "P0", description: "6.467 módulos, BTF, kTLS, initramfs e gates ainda pendentes.", href: "../patch-FreeBSD-Noble/results/BUILD_GENERIC_PROD_6.8.4_2026-08-18.md", tags: "noble build modules btf initramfs" },
  { title: "Build Linux vanilla 7.1.8", area: "evidence", status: "compilado", priority: "P1", description: "NTSYNC, kTLS, BTF, sched_ext, módulos e ausência de boot.", href: "../patch-FreeBSD-Kernel-7.1.8/results/BUILD_PLAYOS_7.1.8_2026-08-18.md", tags: "linux 7.1.8 build sched_ext ntsync" },
  { title: "Resultados dos estudos sys/kern", area: "evidence", status: "medido", priority: "P1", description: "Boottrace, fault injection, scheduler, rede e algoritmos isolados.", href: "../RESULTADOS_ESTUDOS_FREEBSD15_SYS_KERN_2026-08-18.md", tags: "study results benchmark fault injection scheduler" },
  { title: "Base supervisionada", area: "evidence", status: "validado", priority: "P0", description: "Como consultar fontes, datasets, catálogos e política de evidência.", href: "../supervised_learning/README.md", tags: "knowledge rag qa sources governance" },
  { title: "Cobertura e lacunas", area: "evidence", status: "atual", priority: "P1", description: "O que possui cobertura alta, média ou baixa e os próximos gates.", href: "../supervised_learning/evaluations/COVERAGE.md", tags: "coverage gaps validation qa" }
];

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
    card.innerHTML = `
      <div class="doc-meta"><span>${item.status}</span><span class="priority">${item.priority}</span></div>
      <h3>${item.title}</h3>
      <p>${item.description}</p>
      <span class="doc-open">Abrir Markdown →</span>`;
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
