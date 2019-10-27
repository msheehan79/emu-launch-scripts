import QtQuick 2.6

TextInput {
    property alias placeholderText: placeholder.text

    font.pixelSize: baseFontSize
    height: font.pixelSize * 2.5
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: baseFontSize * 0.5
    rightPadding: leftPadding

    selectByMouse: true
    clip: true

    color: acceptableInput ? "#111" : "#f11"

    Rectangle {
        z: -1
        anchors.fill: parent
        color: "#eee"
    }

    Text {
        id: placeholder
        font.pixelSize: baseFontSize
        font.italic: true
        padding: font.pixelSize * 0.5
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.35
        visible: !parent.text
    }
}
