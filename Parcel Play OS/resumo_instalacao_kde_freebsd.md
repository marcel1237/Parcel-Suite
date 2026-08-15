# Resumo da Instalação do KDE no FreeBSD

Este documento resume as soluções e comandos discutidos no chat para instalar o ambiente gráfico KDE Plasma no FreeBSD e resolver problemas de privilégios de acesso.

---

## 1. Instalação Padrão do KDE
Com acesso de administrador, a instalação e configuração básica do KDE, Xorg e gerenciador de login (SDDM) é feita com os seguintes comandos:

```bash
# Atualizar e instalar pacotes
pkg update
pkg install -y xorg sddm kde

# Configurar o sistema de arquivos procfs
sysrc -f /etc/fstab proc /proc procfs rw 0 0
mount -a

# Ativar os serviços básicos na inicialização
sysrc dbus_enable="YES"
sysrc sddm_enable="YES"

# Otimizar buffers de rede locais para o subsistema do KDE
echo "net.local.stream.recvspace=65536" >> /etc/sysctl.conf
echo "net.local.stream.sendspace=65536" >> /etc/sysctl.conf

# Adicionar usuário aos grupos necessários e reiniciar
pw groupmod video -m SEU_USUARIO
pw groupmod wheel -m SEU_USUARIO
reboot
```

---

## 2. Resolvendo "Insufficient Privileges" (Privilégios Insuficientes)
Se os comandos falharem por falta de permissão, você deve rodá-los como **root** utilizando:
```bash
su -
```
Ou utilizando `sudo` antes de cada comando (caso o `sudo` esteja instalado e configurado).

---

## 3. Resolvendo Erro "BAD SU"
O erro `BAD SU` ocorre se a senha do root estiver errada ou se o seu usuário não pertencer ao grupo administrador `wheel`. Para recuperar o acesso:

### Recuperação via Single-User Mode (Modo de Usuário Único)
1. Reinicie o FreeBSD.
2. No menu de boot, pressione **`2`** para selecionar **"Boot Single User"**.
3. Pressione **Enter** quando solicitado para abrir o shell (`/bin/sh`).
4. Execute os comandos abaixo para liberar a escrita no disco e corrigir as permissões:

```bash
# Remontar o sistema como leitura e escrita
mount -u /
mount -a

# Forçar a inclusão do seu usuário no grupo wheel
pw groupmod wheel -m SEU_USUARIO

# (Opcional) Redefinir a senha do root se tiver esquecido
passwd root

# Reiniciar o sistema de volta ao modo normal
reboot
```