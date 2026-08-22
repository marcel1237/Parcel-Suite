import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: slideshow
    color: "#232629" // Breeze Dark Background
    width: 800
    height: 600

    property int currentSlide: 0

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: currentSlide = (currentSlide + 1) % slides.count
    }

    StackLayout {
        id: slides
        anchors.fill: parent
        currentIndex: currentSlide

        // Slide 1: Welcome
        Rectangle {
            color: "transparent"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    text: "Bem-vindo ao Parcel Play OS"
                    color: "#eff0f1"
                    font.pixelSize: 32
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Infraestrutura PlayOS com Kernel NitroCore"
                    color: "#3daee9"
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Slide 2: NitroCore
        Rectangle {
            color: "transparent"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    text: "Potência NitroCore"
                    color: "#eff0f1"
                    font.pixelSize: 32
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Otimização de hardware em tempo real para jogos e produtividade."
                    color: "#a1a9b1"
                    font.pixelSize: 18
                    Layout.preferredWidth: 600
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Slide 3: Compatibilidade
        Rectangle {
            color: "transparent"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                Text {
                    text: "Compatibilidade Universal"
                    color: "#eff0f1"
                    font.pixelSize: 32
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Windows (Proton), Android (Waydroid) e Arch (AUR) rodando nativamente."
                    color: "#a1a9b1"
                    font.pixelSize: 18
                    Layout.preferredWidth: 600
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    // Page Indicator
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        spacing: 10
        Repeater {
            model: slides.count
            Rectangle {
                width: 12; height: 12
                radius: 6
                color: index === currentSlide ? "#3daee9" : "#31363b"
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
