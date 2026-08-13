import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

import calamares.ui 1.0

View {
    id: kernelSelectorPage
    title: qsTr("Personalidade do Sistema (NitroCore)")

    ListModel {
        id: kernelModel
        // Gamer & Performance
        ListElement { name: "Arch"; flavor: "arch"; category: "Performance"; desc: "Simplicidade e vanguarda. Kernel puro."; icon: "distributor-logo-archlinux" }
        ListElement { name: "Fedora"; flavor: "fedora"; category: "Performance"; desc: "Inovação tecnológica e drivers novos."; icon: "distributor-logo-fedora" }
        ListElement { name: "openSUSE"; flavor: "opensuse"; category: "Performance"; desc: "Estabilidade com gestão profissional."; icon: "distributor-logo-opensuse" }

        // Enterprise & Estabilidade
        ListElement { name: "Debian"; flavor: "debian"; category: "Enterprise"; desc: "O padrão ouro de compatibilidade (Recomendado)."; icon: "distributor-logo-debian" }
        ListElement { name: "CentOS"; flavor: "centos"; category: "Enterprise"; desc: "Infraestrutura de missão crítica RHEL."; icon: "distributor-logo-centos" }
        ListElement { name: "Oracle"; flavor: "oracle"; category: "Enterprise"; desc: "Alta performance de I/O e Banco de Dados."; icon: "distributor-logo-oracle" }

        // Segurança & Controle
        ListElement { name: "OpenBSD"; flavor: "openbsd"; category: "Segurança"; desc: "Segurança proativa absoluta."; icon: "security-high" }
        ListElement { name: "FreeBSD"; flavor: "freebsd"; category: "Segurança"; desc: "Excelência em rede e liberdade BSD."; icon: "network-workgroup" }
        ListElement { name: "NetBSD"; flavor: "seguranca"; category: "Segurança"; desc: "Portabilidade universal extrema."; icon: "applications-system" }
        ListElement { name: "Gentoo"; flavor: "gentoo"; category: "Segurança"; desc: "Controle total e otimização de compilação."; icon: "distributor-logo-gentoo" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Kirigami.Heading {
            text: qsTr("Escolha o cérebro do seu Parcel Play OS")
            level: 1
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Cada 'Sabor' do NitroCore herda otimizações de um dos 10 sistemas líderes do mundo.")
            color: Kirigami.Theme.disabledTextColor
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Search/Filter placeholder
        TextField {
            id: searchField
            placeholderText: qsTr("Filtrar kernels...")
            Layout.fillWidth: true
            onTextChanged: {
                // Lógica de filtro aqui
            }
        }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: parent.width / 2
            cellHeight: 120
            model: kernelModel
            clip: true

            delegate: Kirigami.AbstractCard {
                width: grid.cellWidth - 10
                height: grid.cellHeight - 10

                contentItem: RowLayout {
                    spacing: 15

                    Kirigami.Icon {
                        source: model.icon
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                    }

                    ColumnLayout {
                        spacing: 2
                        Label {
                            text: model.name
                            font.bold: true
                            font.pointSize: 12
                        }
                        Label {
                            text: model.category
                            font.pointSize: 8
                            color: model.category === "Enterprise" ? "#3daee9" : (model.category === "Performance" ? "#27ae60" : "#da4453")
                        }
                        Label {
                            text: model.desc
                            font.pointSize: 9
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            maximumLineCount: 2
                        }
                    }
                }

                onClicked: {
                    updateStorage(model.flavor)
                    // Visual feedback de seleção (ex: borda azul)
                }
            }
        }

        Button {
            text: qsTr("Dúvida? Usar o Modo Inteligente (Recomendado)")
            icon.name: "state-ok"
            highlighted: true
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                updateStorage("debian")
                // Feedback visual e avançar para próxima página
            }
        }
    }

    function updateStorage(value) {
        calamares.globalStorage.insert("selected_nitro_flavor", value);
        libcalamares.utils.debug("Sabor de Kernel selecionado: " + value);
    }

    Component.onCompleted: updateStorage("debian") // Default
}
