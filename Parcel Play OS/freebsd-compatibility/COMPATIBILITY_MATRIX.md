# Matriz de compatibilidade

| Carga | Backend primário | Fallback | Observação |
|---|---|---|---|
| aplicações FreeBSD | `pkg`/Ports | build isolado | suporte nativo é prioridade |
| CLI/servidor Linux | Linux jail | bhyve Linux | validar syscalls e filesystem |
| GUI Linux simples | Linux jail + X/Wayland | bhyve Linux | integração gráfica varia por aplicativo |
| Steam/Proton Linux | experimento Linuxulator | bhyve Linux | não prometer catálogo completo |
| Windows comum | Wine nativo | bhyve Windows | testar prefixo por aplicativo |
| jogo com anti-cheat de kernel | nenhum nativo | Windows/Linux em bhyve ou streaming | passthrough e política do fornecedor decidem |
| Android/Waydroid | nenhum nativo | VM Linux/Android | Waydroid requer recursos do kernel Linux |
| Docker Linux | Linux jail apenas quando compatível | VM Linux | container Linux não traz kernel Linux |
| OCI FreeBSD | Podman/jail FreeBSD | jail clássico | imagens FreeBSD são caminho nativo |
| CUDA/ROCm específico de Linux | nenhum genérico | VM Linux com passthrough ou host remoto | depende de GPU/IOMMU/driver |
| desktop KDE/GNOME | FreeBSD nativo | compositor/desktop alternativo | qualificar GPU por modelo |
| ZFS, rede e serviços | FreeBSD nativo | — | manter vantagens nativas |

## Semântica de estado

- **nativo:** API e kernel FreeBSD, suportados por pacote/port testado;
- **compatível:** roda por ABI de userspace, com limitações registradas;
- **virtualizado:** roda em outro kernel, com custo e isolamento claros;
- **experimental:** existe caminho conhecido, mas falta teste reproduzível;
- **bloqueado:** não há backend comprovado para a combinação atual.

“Compatível com tudo” significa que cada carga recebe um caminho e um fallback,
não que todo binário execute diretamente sobre o kernel FreeBSD.
