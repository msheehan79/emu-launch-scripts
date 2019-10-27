import QtQuick 2.6

Text {
    font.pixelSize: baseFontSize * 1.1
    anchors.verticalCenter: parent.verticalCenter
    padding: font.pixelSize * 0.5
    leftPadding: padding * 1.25
    rightPadding: leftPadding
    elide: Text.ElideRight
}
