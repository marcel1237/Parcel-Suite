#!/usr/bin/env python3
import libcalamares
import subprocess
import os

def run():
    """
    Executa o Subiquity usando o arquivo autoinstall gerado.
    """
    libcalamares.utils.debug("PlayOS Backend: Iniciando Subiquity...")

    config_path = "/tmp/playos-autoinstall.yaml"

    if not os.path.exists(config_path):
        return (False, "Arquivo de configuração não encontrado", f"O caminho {config_path} não existe.")

    # Comando para rodar o subiquity em modo servidor com autoinstall
    # Nota: Em ambiente Desktop, podemos usar o subiquity-server ou o snap diretamente.
    cmd = [
        "subiquity",
        "--autoinstall", config_path
    ]

    try:
        # Redirecionar saída para o log do Calamares
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

        for line in process.stdout:
            libcalamares.utils.debug(f"[Subiquity] {line.strip()}")

        process.wait()

        if process.returncode != 0:
            return (False, f"Subiquity falhou com código {process.returncode}", "Verifique os logs acima.")

    except Exception as e:
        libcalamares.utils.warning(f"Erro ao executar Subiquity: {str(e)}")
        return (False, "Falha na execução do backend de instalação", str(e))

    libcalamares.utils.debug("PlayOS Backend: Instalação concluída pelo Subiquity.")
    return None
