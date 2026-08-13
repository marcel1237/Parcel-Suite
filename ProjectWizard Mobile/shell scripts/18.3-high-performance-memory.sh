#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Project Wizard - Etapa 18.3"
echo " Ajuste de Memória de Alta Performance"
echo "========================================="

# 1. Validar ambiente
if [ ! -f pom.xml ]; then
    echo "Erro: Execute na raiz do ProjectWizard."
    exit 1
fi

echo "[1/2] Elevando Heap para 4GB e otimizando GC no pom.xml..."
python3 <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path

path = Path("pom.xml")
ET.register_namespace('', "http://maven.apache.org/POM/4.0.0")
tree = ET.parse(path)
root = tree.getroot()
ns = {'m': 'http://maven.apache.org/POM/4.0.0'}

found = False
for plugin in root.findall('.//m:plugin', ns):
    art_id = plugin.find('m:artifactId', ns)
    if art_id is not None and art_id.text == 'javafx-maven-plugin':
        config = plugin.find('m:configuration', ns)
        options = config.find('m:options', ns)
        
        # Limpa opções antigas de memória
        for opt in options.findall('m:option', ns):
            if opt.text.startswith('-Xmx') or opt.text.startswith('-XX'):
                options.remove(opt)
        
        # Adiciona 4GB de RAM
        opt_mem = ET.SubElement(options, 'option')
        opt_mem.text = '-Xmx4g'
        
        # Adiciona o Garbage Collector G1 (Melhor para IDEs)
        opt_gc = ET.SubElement(options, 'option')
        opt_gc.text = '-XX:+UseG1GC'
        
        found = True
        break

if found:
    tree.write(path, encoding='utf-8', xml_declaration=True)
    print("✔ pom.xml atualizado para 4GB + G1GC.")
else:
    print("❌ Falha ao localizar o plugin no pom.xml.")
PY

echo "[2/2] Configurando variável de ambiente para o Maven..."
export MAVEN_OPTS="-Xmx4g -XX:+UseG1GC"

echo "========================================="
echo " 🎉 ETAPA 18.3 CONCLUÍDA!"
echo "========================================="
echo "Dica: Se sua máquina tiver menos de 8GB de RAM total,"
echo "feche outros programas (como o Chrome) antes de rodar."
echo "========================================="
echo "🚀 Tente agora: mvn javafx:run"