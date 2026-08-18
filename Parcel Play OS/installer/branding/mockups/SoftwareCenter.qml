import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: 1024
    height: 768
    title: "Parcel Software Center"

    pageStack.initialPage: Kirigami.ScrollablePage {
        title: "Nitro-Universal Search"

        actions: [
            Kirigami.Action {
                text: "Configurações"
                icon.name: "settings-configure"
            },
            Kirigami.Action {
                text: "Atualizações"
                icon.name: "system-software-update"
            }
        ]

        ColumnLayout {
            spacing: 20

            // 1. Search Bar
            TextField {
                id: searchInput
                placeholderText: "Pesquisar aplicativos em todos os ecossistemas (AUR, APT, COPR, Flathub)..."
                Layout.fillWidth: true
                Layout.margins: 10
                leftPadding: 40
                background: Rectangle {
                    color: "#31363b"
                    radius: 20
                    border.color: searchInput.activeFocus ? "#3daee9" : "transparent"

                    Kirigami.Icon {
                        source: "search"
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24; height: 24
                    }
                }
            }

            // 2. Category Header
            Kirigami.Heading {
                text: "Resultados Híbridos para '" + searchInput.text + "'"
                visible: searchInput.text !== ""
                Layout.leftMargin: 10
            }

            // 3. Application Cards
            Kirigami.CardsListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ListModel {
                    ListElement { name: "Visual Studio Code"; source: "Arch AUR"; icon: "com.visualstudio.code"; desc: "Editor de código vanguarda (Pacman/Yay)"; nitro: true }
                    ListElement { name: "GIMP"; source: "Ubuntu Base"; icon: "gimp"; desc: "Editor de imagem estável (APT)"; nitro: false }
                    ListElement { name: "Steam"; source: "Parcel Games"; icon: "steam"; desc: "Plataforma de jogos otimizada para NitroCore"; nitro: true }
                    ListElement { name: "LibreOffice"; source: "Flathub"; icon: "libreoffice-main"; desc: "Suíte de escritório em sandbox (Flatpak)"; nitro: false }
                }

                delegate: Kirigami.AbstractCard {
                    contentItem: RowLayout {
                        spacing: 20

                        Kirigami.Icon {
                            source: model.icon
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 64
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Label { text: model.name; font.bold: true; font.pointSize: 14 }
                            Label {
                                text: "Fonte: " + model.source
                                color: model.source.includes("Arch") ? "#1793d1" : (model.source.includes("Ubuntu") ? "#dd4814" : "#3daee9")
                            }
                            Label { text: model.desc; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                            RowLayout {
                                visible: model.nitro
                                Kirigami.Icon { source: "speedometer"; color: "#27ae60"; width: 16; height: 16 }
                                Label { text: "Nitro-Optimized"; color: "#27ae60"; font.italic: true }
                            }
                        }

                        Button {
                            text: "Instalar"
                            highlighted: true
                            onClicked: console.log("Instalando via " + model.source)
                        }
                    }
                }
            }
        }
    }
}
