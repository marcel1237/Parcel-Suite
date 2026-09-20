# Guia: Como Criar uma Distribuição Baseada em Ubuntu (2024-2025)

Este documento resume as melhores práticas e ferramentas para criar uma "remix" ou distribuição personalizada baseada no Ubuntu (focando nas versões 24.04 Noble e futuras).

---

## 1. Comparativo de Métodos

| Critério | **Cubic** (Remaster) | **Imagecraft** (Official) | **live-build** (Granular) | **Autoinstall** (Deployment) |
| :--- | :--- | :--- | :--- | :--- |
| **Dificuldade** | Baixa (GUI) | Média (YAML) | Alta (CLI/Scripts) | Média (YAML) |
| **Velocidade** | Muito Rápida | Média | Lenta | Rápida |
| **Reprodutibilidade** | Baixa (Manual) | Alta (Scriptada) | Máxima | Alta |
| **Uso Ideal** | Protótipos e ISOs rápidas | Produtos Oficiais | Controle total do sistema | Frotas e Servidores |

---

## 2. O Caminho Mais Fácil e Rápido: **Cubic**
O **Cubic** (Custom Ubuntu ISO Creator) é um assistente gráfico que automatiza a extração e reconstrução da ISO.

### Como funciona:
1.  Você baixa a ISO oficial do Ubuntu (ex: 24.04 LTS).
2.  O Cubic abre um terminal (chroot) dentro do sistema de arquivos da ISO.
3.  Você instala pacotes (`apt install`), altera papéis de parede e modifica arquivos de configuração.
4.  O assistente reconstrói a imagem bootável automaticamente.

### Comandos para instalação:
```bash
sudo add-apt-repository ppa:cubic-wizard/release
sudo apt update
sudo apt install cubic
```

---

## 3. O Caminho Profissional e Moderno: **Imagecraft**
O **Imagecraft** é a nova ferramenta oficial da Canonical que utiliza arquivos YAML para definir a distribuição.

### Vantagens:
- **Reprodutibilidade**: Você pode versionar o arquivo `.yaml`. Se precisar mudar um detalhe, basta alterar o texto e rodar o build novamente.
- **Parts**: Funciona como o Snapcraft, permitindo puxar componentes de diferentes fontes (git, deb, scripts).

### Comandos:
```bash
snap install imagecraft --beta --classic
# O build é feito via:
imagecraft pack
```

---

## 4. O Caminho de "Baixo Nível": **live-build**
É o método que o projeto PlayOS utilizou até agora. É o mesmo motor usado pelo **Debian** para criar suas imagens oficiais.

### Por que usar?
- Permite trocar o initramfs (ex: usar `live-boot` em vez de `casper`).
- Controle total sobre como o kernel é inserido e como o GRUB é configurado.
- É ideal para o PlayOS porque estamos misturando Kernel Noble com Userspace Debian.

---

## 5. Estratégia Recomendada para o PlayOS

Dado o estado atual do projeto, a melhor maneira depende do seu objetivo imediato:

### A. Se você quer testar um visual novo em 5 minutos:
Use o **Cubic**. É visual, você vê o que está fazendo e gera a ISO sem lidar com erros de script complexos.

### B. Se você quer que a ISO seja "oficial" e fácil de manter:
Migre para o **Imagecraft**. Ele permite que você defina o kernel do PlayOS e os pacotes KDE/XFCE em um arquivo YAML limpo, facilitando para outros desenvolvedores recriarem a imagem idêntica à sua.

### C. Se você quer máxima leveza e customização de kernel (Estado Atual):
Continue com o **live-build**, mas seguindo o **Manual de Criação via VMs** que criamos, para evitar conflitos de permissão do host.

---

## Dicas de Ouro para 2025
1.  **Remova o Snaps**: Muitas distros baseadas em Ubuntu removem o `snapd` para ganhar velocidade e espaço.
2.  **Branding**: Coloque seus arquivos em `/etc/skel` para que todo novo usuário criado já venha com seu papel de parede e ícones.
3.  **Kernel**: O Ubuntu 25.04 (Plucky Puffin) usará o Kernel 6.14. Se o PlayOS pretende ser vanguardista, acompanhar essa base é essencial.

**Veredito:** Para rapidez absoluta, use **Cubic**. Para qualidade de engenharia, use **Imagecraft**.
