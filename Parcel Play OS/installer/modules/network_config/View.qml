import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

import calamares.ui 1.0

View {
    id: networkConfigPage
    title: qsTr("Configuração de Rede Nitro-Net")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        Kirigami.Heading {
            text: qsTr("Otimização de Rede (Inspirado no FreeBSD)")
            level: 1
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("O Parcel Play OS utiliza a tecnologia Nitro-Net para reduzir o ping e aumentar a vazão de dados.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            CheckBox {
                id: checkZeroCopy
                text: "Habilitar Zero-Copy Networking"
                checked: true
                Kirigami.FormData.label: "Aceleração:"
                ToolTip.visible: hovered
                ToolTip.text: "Reduz o uso de CPU ao processar pacotes (Netflix/FreeBSD Style)."
            }

            CheckBox {
                id: checkLowLatency
                text: "Modo Ultra-Baixa Latência (Gaming)"
                checked: true
                ToolTip.visible: hovered
                ToolTip.text: "Prioriza pacotes de jogos no Kernel NitroCore."
            }

            ComboBox {
                id: comboCongestion
                model: ["BBR (Google/Vanguard)", "Cubic (Standard)", "Veno (Wireless Opt)"]
                Kirigami.FormData.label: "Algoritmo de Congestionamento:"
            }
        }

        Item { Layout.fillHeight: true }

        Kirigami.InlineMessage {
            type: Kirigami.MessageType.Information
            text: "Essas configurações serão aplicadas diretamente ao kernel Nitro-Net via sysctl e XDP."
            Layout.fillWidth: true
            visible: true
        }
    }

    function updateStorage() {
        calamares.globalStorage.insert("nitro_net_zerocopy", checkZeroCopy.checked);
        calamares.globalStorage.insert("nitro_net_lowlatency", checkLowLatency.checked);
        calamares.globalStorage.insert("nitro_net_congestion", comboCongestion.currentText);
    }

    Component.onDestruction: updateStorage()
}
