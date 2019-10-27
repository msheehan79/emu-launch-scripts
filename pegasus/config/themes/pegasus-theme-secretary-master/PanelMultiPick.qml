import QtQuick 2.6
import QtQuick.Window 2.2

Row {
    property var initialModel: []

    readonly property alias model: repeater.model
    onInitialModelChanged: repeater.model = initialModel
        .filter(v => v)
        .map(v => ({ name: v, selected: false }))


    property bool panelOpen: false
    readonly property int closedHeight: baseFontSize * 2.5
    readonly property int openHeight: Math.max(closedHeight, Math.min(flow.height + flick.bottomMargin, Window.window.height * 0.4))

    function togglePanel() {
        flick.contentY = 0;
        panelOpen = !panelOpen;
    }


    width: parent.secondColumnW
    height: panelOpen ? openHeight : closedHeight
    clip: true

    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }


    Flickable {
        id: flick
        width: parent.width - toggle.width
        height: parent.height
        contentHeight: flow.height
        boundsBehavior: Flickable.OvershootBounds
        bottomMargin: baseFontSize
        interactive: panelOpen

        Flow {
            id: flow
            width: parent.width
            spacing: baseFontSize * 0.5

            Repeater {
                id: repeater
                model: []
                delegate: delegate
            }
        }
    }

    PanelToggler {
        id: toggle
        isLeftSide: false
        isOpen: panelOpen
        onClicked: togglePanel()
        padding: baseFontSize * 0.25
    }

    Component {
        id: delegate

        Text {
            text: modelData.name
            font.pixelSize: baseFontSize
            height: font.pixelSize * 2
            padding: font.pixelSize * 0.5
            color: modelData.selected ? "#fff" : "#111"
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                color: {
                    if (modelData.selected) return "#37e";
                    if (mouse.containsMouse) return "#ade";
                    return "#eee";
                }
                radius: parent.padding
                z: -1
            }

            MouseArea {
                id: mouse
                hoverEnabled: true
                anchors.fill: parent
                onClicked: {
                    const new_model = repeater.model;
                    new_model[index].selected = !modelData.selected;
                    repeater.model = new_model;
                }
            }
        }
    }
}
