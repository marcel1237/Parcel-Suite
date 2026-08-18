import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: 1100
    height: 800
    title: "Nitro-Control Center"

    pageStack.initialPage: Kirigami.ScrollablePage {
        title: "NitroCore Dashboard"

        Kirigami.CardsListView {
            Layout.fillWidth: true
            model: ListModel {
                ListElement {
                    name: "Perfil Nitro-Boost";
                    status: "Gaming Mode Ativo";
                    icon: "speedometer";
                    color: "#27ae60";
                    desc: "Otimizando para 1000Hz (Arch BORE logic)."
                }
                ListElement {
                    name: "Sabor de Kernel";
                    status: "Flavor: Fedora (NTSYNC)";
                    icon: "applications-system";
                    color: "#3daee9";
                    desc: "Sincronização NT ativa para jogos Windows."
                }
                ListElement {
                    name: "Nitro-Jail Security";
                    status: "7 Prisões Ativas";
                    icon: "security-high";
                    color: "#da4453";
                    desc: "Aplicativos isolados via Namespaces (OpenBSD style)."
                }
                ListElement {
                    name: "Zonas de Agilidade";
                    status: "Arch/AUR Conectado";
                    icon: "distributor-logo-archlinux";
                    color: "#1793d1";
                    desc: "Pacman 7.0 gerenciando a camada vanguarda."
                }
            }

            delegate: Kirigami.AbstractCard {
                contentItem: ColumnLayout {
                    spacing: 10
                    RowLayout {
                        spacing: 15
                        Kirigami.Icon {
                            source: model.icon
                            color: model.color
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                        }
                        ColumnLayout {
                            Label { text: model.name; font.bold: true; font.pointSize: 12 }
                            Label { text: model.status; color: model.color; font.pointSize: 9 }
                        }
                    }
                    Kirigami.Separator { Layout.fillWidth: true }
                    Label {
                        text: model.desc
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                    }
                    Button {
                        text: "Configurar"
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }
        }

        Kirigami.PlaceholderMessage {
            visible: searchInput.text !== "" && grid.count === 0
            text: "Nenhum módulo Nitro encontrado."
        }
    }
}
