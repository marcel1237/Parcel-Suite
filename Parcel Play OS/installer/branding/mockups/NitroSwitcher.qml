import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

Kirigami.ApplicationWindow {
    id: root
    width: 350
    height: 450
    title: "Nitro-Switcher"

    pageStack.initialPage: Kirigami.ScrollablePage {
        title: "NitroCore Engine"

        ColumnLayout {
            spacing: 20
            anchors.fill: parent
            anchors.margins: 15

            // 1. Current Kernel Display
            Kirigami.AbstractCard {
                Layout.fillWidth: true
                contentItem: ColumnLayout {
                    Label { text: "Núcleo Ativo"; font.bold: true; font.pointSize: 10 }
                    RowLayout {
                        Kirigami.Icon { source: "speedometer"; color: "#27ae60"; width: 32; height: 32 }
                        ColumnLayout {
                            Label { text: "Flavor Arch (BORE)"; font.pixelSize: 18; font.bold: true }
                            Label { text: "Status: Performance Máxima"; color: "#27ae60" }
                        }
                    }
                }
            }

            // 2. Flavor Selection
            Label { text: "Trocar Sabor para o próximo Boot:"; font.bold: true }

            ComboBox {
                id: flavorSelector
                Layout.fillWidth: true
                model: ["Arch (Performance)", "Fedora (Windows Sync)", "openSUSE (Stability)", "Debian (Compatibility)", "Gentoo (Source Opt)", "FreeBSD (Network)", "OpenBSD (Hardened)", "NetBSD (Portability)", "CentOS (Mission Critical)", "Oracle (Database I/O)"]

                currentIndex: 0
            }

            // 3. Action Buttons
            Button {
                text: "Agendar Mudança"
                icon.name: "document-save"
                Layout.fillWidth: true
                onClicked: console.log("Nitro-Switcher: Próximo boot definido para " + flavorSelector.currentText)
            }

            Button {
                text: "Aplicar e Reiniciar Agora"
                icon.name: "system-reboot"
                Layout.fillWidth: true
                highlighted: true
                onClicked: {
                    // Chama script nitro-switcher-apply.sh [index]
                    console.log("Nitro-Switcher: Executando grub-reboot...")
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            Label {
                text: "Dica: O sistema voltará para o Flavor Debian caso a inicialização falhe."
                font.pointSize: 8
                color: Kirigami.Theme.disabledTextColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
