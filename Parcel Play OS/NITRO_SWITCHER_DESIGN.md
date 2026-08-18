# Design de Interface: Nitro-Switcher Widget

O **Nitro-Switcher** é um widget de alta performance para o painel do **KDE Plasma 6** que permite ao usuário gerenciar e alternar entre os 10 sabores do kernel **NitroCore** sem precisar entrar em menus complexos.

## 1. Funcionalidade Principal
O widget oferece uma interface de "Um Clique" para preparar o sistema para a próxima inicialização:
1.  **Status Atual**: Exibe qual o Sabor de kernel está ativo (Ex: "Flavor Arch").
2.  **Seletor de Próximo Boot**: Lista as 10 opções do Decágono.
3.  **Handoff Acelerado**: Ao selecionar um novo sabor, o widget utiliza o comando `sudo grub-reboot [index]` e oferece um botão de **"Reinício Instantâneo"**.

## 2. Protótipo Visual (QML/Plasma)

```qml
import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    width: 250; height: 100

    ColumnLayout {
        anchors.fill: parent
        Label { text: "NitroCore Ativo: " + currentKernel; font.bold: true }
        
        ComboBox {
            id: flavorSelector
            model: ["Arch", "Fedora", "openSUSE", "Debian", "Gentoo", "FreeBSD", "OpenBSD", "NetBSD", "CentOS", "Oracle"]
            Layout.fillWidth: true
        }

        Button {
            text: "Aplicar e Reiniciar"
            icon.name: "system-reboot"
            onClicked: {
                // Chama script nitro-switcher-apply.sh [flavor]
                // Executa sudo grub-reboot
            }
        }
    }
}
```

## 3. Integração com o GRUB
O widget utiliza a variável `GRUB_DEFAULT=saved` para garantir que o kernel escolhido seja carregado apenas no próximo boot, voltando para o padrão (**Debian**) caso ocorra algum problema.

---
*Status: Design de Widget concluído.*
