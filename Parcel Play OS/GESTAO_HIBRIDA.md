# Gestão Híbrida: APT + Pacman (O Melhor dos Dois Mundos)

O **Parcel Play OS** resolve o maior dilema do Linux: escolher entre a estabilidade do **Debian/Ubuntu** e a agilidade/vanguarda do **Arch Linux**.

## 1. Arquitetura de Camadas

O sistema é dividido em duas zonas de pacotes:

### Zona A: Estabilidade (Host - Ubuntu 26)
- **Gerenciador**: `APT` e `Snap`.
- **Estado**: **Imutável** (Read-Only Rootfs).
- **Função**: Gerir o Kernel NitroCore, drivers de vídeo, firmware e a interface de desktop (Gnome/KDE).
- **Vantagem**: O sistema nunca quebra. Atualizações são atômicas e seguras.

### Zona B: Agilidade (Contêiner - Arch Linux)
- **Gerenciador**: `Pacman` e `Yay` (AUR).
- **Estado**: Mutável (dentro do contêiner).
- **Função**: Desenvolvimento, apps de vanguarda e qualquer software disponível no **AUR**.
- **Vantagem**: Acesso à maior biblioteca de software do mundo Linux sem afetar a estabilidade do núcleo.

## 2. Integração Transparente (Distrobox)

Utilizamos o **Distrobox** como ponte. Quando você instala um app via Pacman na Zona B, ele é "exportado" automaticamente para o menu do seu sistema:

```bash
# Exemplo de uso:
nitro-arch install visual-studio-code-bin # Usa pacman e yay por baixo dos panos
```

O app aparecerá no seu menu do KDE ou Gnome como se fosse um pacote nativo, mas rodando em um ambiente isolado.

## 3. Parcel Software Center (Híbrido)

A nossa loja unifica a busca:
- Se você busca por "Docker", ela sugere a versão estável do **APT**.
- Se você busca por um driver obscuro ou app de dev, ela sugere a versão do **AUR**.

---
*Filosofia: Estabilidade Ubuntu, Agilidade Arch.*
