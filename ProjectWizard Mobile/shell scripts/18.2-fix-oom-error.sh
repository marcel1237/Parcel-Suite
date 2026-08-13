#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.2"
echo " Corrigindo Erro 137 (Ajuste de Memória)"
echo "========================================="

# 1. Verificar se o pom.xml existe
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do projeto ProjectWizard."
    exit 1
fi

echo "[1/2] Aumentando limites de memória no pom.xml..."
# O script utiliza Python para injetar opções de VM no javafx-maven-plugin
python3 <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path

path = Path("pom.xml")
ET.register_namespace('', "http://maven.apache.org/POM/4.0.0")
tree = ET.parse(path)
root = tree.getroot()
ns = {'m': 'http://maven.apache.org/POM/4.0.0'}

# Localiza o plugin javafx-maven-plugin
found = False
for plugin in root.findall('.//m:plugin', ns):
    art_id = plugin.find('m:artifactId', ns)
    if art_id is not None and art_id.text == 'javafx-maven-plugin':
        config = plugin.find('m:configuration', ns)
        if config is None:
            config = ET.SubElement(plugin, 'configuration')
        
        # Verifica se já existem options
        options = config.find('m:options', ns)
        if options is None:
            options = ET.SubElement(config, 'options')
        
        # Remove opções antigas de memória se existirem para evitar duplicidade
        for opt in options.findall('m:option', ns):
            if opt.text.startswith('-Xmx'):
                options.remove(opt)
        
        # Adiciona 2GB de memória máxima
        new_mem = ET.SubElement(options, 'option')
        new_mem.text = '-Xmx2g'
        
        # Adiciona suporte a reflexão para bibliotecas internas se necessário
        new_ref = ET.SubElement(options, 'option')
        new_ref.text = '--add-exports=javafx.graphics/com.sun.javafx.application=ALL-UNNAMED'
        
        found = True
        break

if found:
    tree.write(path, encoding='utf-8', xml_declaration=True)
    print("✔ pom.xml atualizado com -Xmx2g.")
else:
    print("❌ Falha: javafx-maven-plugin não encontrado no pom.xml.")
PY

echo "[2/2] Limpando artefatos de build anteriores..."
mvn clean > /dev/null

echo "========================================="
echo " 🎉 ETAPA 18.2 CONCLUÍDA!"
echo "========================================="
echo "Alteração: Adicionado -Xmx2g ao plugin JavaFX."
echo "Isso impede que o sistema mate o processo por falta de RAM."
echo "========================================="
echo "🚀 Tente rodar novamente: mvn javafx:run"