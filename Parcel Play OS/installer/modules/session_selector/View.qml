import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

import calamares.ui 1.0

View {
    id: sessionSelectorPage
    title: qsTr("Escolha sua Experiência")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 30

        Kirigami.Heading {
            text: qsTr("Como você deseja usar seu Parcel Play OS?")
            level: 1
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 40

            // Card 1: Sessão Basic (Gnome)
            Kirigami.AbstractCard {
                id: cardBasic
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 400

                showClickFeedback: true
                highlighted: calamares.globalStorage.value("selected_session") === "basic"

                contentItem: ColumnLayout {
                    spacing: 20
                    anchors.margins: 20

                    Kirigami.Icon {
                        source: "playos-logo"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Kirigami.Heading {
                        text: "Sessão Basic"
                        level: 2
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Ambiente GNOME puro, focado em estabilidade, simplicidade e produtividade sem distrações."
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                    }

                    Kirigami.Separator { Layout.fillWidth: true }

                    ColumnLayout {
                        spacing: 5
                        Label { text: "• Interface limpa"; font.pointSize: 9 }
                        Label { text: "• Apps essenciais Gnome"; font.pointSize: 9 }
                        Label { text: "• Máxima estabilidade"; font.pointSize: 9 }
                    }
                }

                onClicked: updateStorage("basic")
            }

            // Card 2: Sessão Full (KDE)
            Kirigami.AbstractCard {
                id: cardFull
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 400

                showClickFeedback: true
                highlighted: calamares.globalStorage.value("selected_session") === "full"

                contentItem: ColumnLayout {
                    spacing: 20
                    anchors.margins: 20

                    Kirigami.Icon {
                        source: "distributor-logo-kubuntu"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Kirigami.Heading {
                        text: "Sessão Full"
                        level: 2
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Ambiente KDE Plasma completo, com personalização Parcel Suite e máxima integração ao NitroCore."
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        color: Kirigami.Theme.disabledTextColor
                    }

                    Kirigami.Separator { Layout.fillWidth: true }

                    ColumnLayout {
                        spacing: 5
                        Label { text: "• Customização extrema"; font.pointSize: 9 }
                        Label { text: "• Integração Thunder SDK"; font.pointSize: 9 }
                        Label { text: "• Foco em Jogos e Performance"; font.pointSize: 9 }
                    }
                }

                onClicked: updateStorage("full")
            }
        }

        Label {
            text: qsTr("Você poderá trocar entre os ambientes após a instalação.")
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            color: Kirigami.Theme.disabledTextColor
        }
    }

    function updateStorage(value) {
        calamares.globalStorage.insert("selected_session", value);
        libcalamares.utils.debug("Sessão selecionada: " + value);
    }

    Component.onCompleted: {
        if (!calamares.globalStorage.contains("selected_session")) {
            updateStorage("full") // Default é a experiência completa
        }
    }
}
