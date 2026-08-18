import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: 900
    height: 600
    title: "Central de Segurança Nitro"

    pageStack.initialPage: Kirigami.ScrollablePage {
        title: "Painel de Blindagem"

        ColumnLayout {
            spacing: 20
            anchors.fill: parent
            anchors.margins: 20

            // 1. Status Geral
            Kirigami.InlineMessage {
                Layout.fillWidth: true
                type: Kirigami.MessageType.Positive
                text: "Sistema Íntegro: 100% de Proteção Ativa"
                visible: true
            }

            // 2. Security Grid
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 20
                rowSpacing: 20

                Kirigami.AbstractCard {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        Label { text: "Nitro-Jail (Process Isolation)"; font.bold: true }
                        Label { text: "Status: Ativo (4 Prisões)"; color: "#27ae60" }
                        ProgressBar { value: 0.2; Layout.fillWidth: true }
                    }
                }

                Kirigami.AbstractCard {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        Label { text: "Nitro-Verify (Integrity)"; font.bold: true }
                        Label { text: "Status: Verificado (SHA-512)"; color: "#3daee9" }
                        Label { text: "Última varredura: Agora"; font.pointSize: 8 }
                    }
                }

                Kirigami.AbstractCard {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        Label { text: "CFI Shield"; font.bold: true }
                        Label { text: "Status: Vigilante"; color: "#27ae60" }
                        Label { text: "Zero violações detectadas"; font.pointSize: 8 }
                    }
                }

                Kirigami.AbstractCard {
                    Layout.fillWidth: true
                    contentItem: ColumnLayout {
                        Label { text: "Defesa Baseada em IA"; font.bold: true }
                        Label { text: "Nível: Aprendizagem Ativa"; color: "#f67400" }
                        Button { text: "Ver Relatório de IA"; Layout.alignment: Qt.AlignRight }
                    }
                }
            }

            // 3. Mode Selector
            Kirigami.Heading { text: "Selecionar Perfil de Blindagem"; level: 2 }
            RowLayout {
                spacing: 15
                Button { text: "Modo Gamer"; highlighted: true }
                Button { text: "Modo Padrão" }
                Button { text: "Modo Fortaleza" }
            }
        }
    }
}
