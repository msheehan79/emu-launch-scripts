import QtQuick 2.6

Row {
    property int acceptedMin
    property int acceptedMax

    readonly property int valFrom: inputFrom.acceptableInput ? parseInt(inputFrom.text) : acceptedMin
    readonly property int valTo: inputTo.acceptableInput ? parseInt(inputTo.text) : acceptedMax

    readonly property int min: Math.min(valFrom, valTo)
    readonly property int max: Math.max(valFrom, valTo)

    readonly property int cellW: (width - spacing) / 2

    width: parent.secondColumnW
    spacing: baseFontSize * 0.5


    PanelInputBase {
        id: inputFrom
        placeholderText: "(from any)"
        width: cellW
        validator: IntValidator { bottom: acceptedMin; top: acceptedMax }
    }

    PanelInputBase {
        id: inputTo
        placeholderText: "(to any)"
        width: cellW
        validator: IntValidator { bottom: acceptedMin; top: acceptedMax }
    }
}

