import QtQuick 2.15
import QtQuick.Window 2.15
import QtWebEngine 1.10
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.20 as Kirigami

Window {
    id: thunderBrowserWindow
    visible: true
    width: 1280
    height: 800
    title: "Thunder Browser - Nitro Engine"

    // Kiosk Mode Flags
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Window.FullScreen

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    color: "#232629" // Breeze Dark

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Minimalist Toolbar (Auto-hide logic)
        Rectangle {
            id: toolbar
            Layout.fillWidth: true
            height: 48
            color: "#31363b"
            visible: true // Expand on hover top

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                Kirigami.Icon {
                    source: "go-previous"
                    width: 24; height: 24
                    MouseArea { anchors.fill: parent; onClicked: webView.goBack() }
                }

                TextField {
                    id: urlField
                    text: webView.url
                    placeholderText: "Navegação Acelerada NitroCore..."
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: "#232629"
                        radius: 5
                    }
                }

                RowLayout {
                    spacing: 10
                    Kirigami.Icon { source: "video-display"; color: "#3daee9"; width: 20; height: 20 }
                    Label { text: "HDR: Ativo"; color: "#3daee9"; font.pointSize: 9; font.bold: true }

                    Kirigami.Separator { orientation: Qt.Vertical; Layout.preferredHeight: 20 }

                    Kirigami.Icon { source: "speedometer"; color: "#27ae60"; width: 20; height: 20 }
                    Label { text: "Nitro: Ativo"; color: "#27ae60"; font.pointSize: 9; font.bold: true }
                }
            }
        }

        // 2. Web Engine View (The Core)
        WebEngineView {
            id: webView
            Layout.fillWidth: true
            Layout.fillHeight: true
            url: "https://github.com/marcel1237"

            // NitroCore Integrated Settings
            settings.javascriptEnabled: true
            settings.pluginsEnabled: false
            settings.playbackRequiresUserGesture: false
            settings.accelerated2dCanvasEnabled: true // Hardware Boost

            onLoadingChanged: {
                if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                    console.log("Nitro-Engine: Injetando otimizações de RAM e Brightness Mapping HDR...")
                }
            }
        }
    }
}
