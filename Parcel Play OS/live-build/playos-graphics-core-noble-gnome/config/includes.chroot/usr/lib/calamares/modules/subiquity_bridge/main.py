#!/usr/bin/env python3
import libcalamares
import os
import yaml

def run():
    """
    Traduz o estado do Calamares para o formato Autoinstall do Subiquity.
    """
    libcalamares.utils.debug("PlayOS Bridge: Gerando autoinstall.yaml...")

    gs = libcalamares.globalstorage

    # 1. Coletar dados do usuário
    username = gs.value("userName")
    password = gs.value("userPassword")
    hostname = gs.value("hostname")

    # 2. Coletar decisões PlayOS
    session = gs.value("selected_session") or "full"
    flavor = gs.value("selected_nitro_flavor") or "debian"

    # 3. Montar o dicionário Autoinstall (Simplificado)
    autoinstall = {
        "version": 1,
        "identity": {
            "hostname": hostname,
            "password": password, # Nota: Subiquity espera hash ou plaintext conforme config
            "username": username
        },
        "locale": "pt_BR.UTF-8",
        "keyboard": {
            "layout": "br"
        },
        "ssh": {
            "allow-pw": True,
            "install-server": True
        },
        "storage": {
            "layout": {
                "name": "direct" # Usa o disco inteiro detectado
            }
        },
        "late-commands": [
            f"curtin in-target -- target=/ bash -c 'echo \"selected_session: {session}\" > /etc/playos-session.conf'",
            f"curtin in-target -- target=/ bash -c 'echo \"selected_flavor: {flavor}\" > /etc/playos-flavor.conf'",
            "curtin in-target -- target=/ bash -c 'systemctl enable gdm3.service NetworkManager.service'",
            "curtin in-target -- target=/ bash -c 'cd /cdrom/scripts && ./nitro-post-install.sh'"
        ]
    }

    # 4. Salvar o arquivo
    output_path = "/tmp/playos-autoinstall.yaml"
    try:
        with open(output_path, 'w') as f:
            yaml.dump(autoinstall, f)
        libcalamares.utils.debug(f"PlayOS Bridge: Arquivo salvo em {output_path}")
    except Exception as e:
        libcalamares.utils.warning(f"Erro ao salvar autoinstall.yaml: {str(e)}")
        return (False, "Falha ao gerar configuração do backend", str(e))

    return None
