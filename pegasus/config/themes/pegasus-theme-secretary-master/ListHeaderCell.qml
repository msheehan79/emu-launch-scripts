import QtQuick 2.6

ListRowCell {
    property string baseText: ""
    property bool isActive: false
    property bool isAscending: false

    signal clicked()

    text: {
        let out = baseText;
        if (isActive) {
            out += "  ";
            out += isAscending ? "\u25B2" : "\u25BC";
        }
        return out;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
