import QtQuick 2.6

Item {
    property bool isOpen
    property bool isLeftSide
    property alias padding: text.padding

    signal clicked()

    width: baseFontSize * 4
    height: parent.height

    Text {
        id: text
        text: isLeftSide ? "\u25B6" : "\u25C0"
        rotation: isOpen ? (isLeftSide ? 90 : -90) : 0
        font.pixelSize: baseFontSize
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on rotation { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
