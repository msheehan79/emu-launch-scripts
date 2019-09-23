import QtQuick 2.6

Component {
    id: gameAxisDelegate

    Item {
        width: vpx(240)
        height: vpx(135)

        Rectangle {
            anchors.fill: parent
            color: "#333"
            visible: image.status !== Image.Ready

            Text {
                text: modelData.title

                anchors.fill: parent
                anchors.margins: vpx(12)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap

                color: "white"
                font.pixelSize: vpx(16)
                font.family: globalFonts.sans
            }
        }

        Image {
            id: image

            anchors.fill: parent
            visible: source

            fillMode: Image.PreserveAspectCrop

            asynchronous: true
            source: assets.banner || (assets.screenshots && assets.screenshots[0]) || assets.boxFront || assets.steam
            sourceSize { width: 256; height: 256; }

            Image {
                anchors.fill: parent
                anchors.margins: parent.width * 0.1
                fillMode: Image.PreserveAspectFit
                source: assets.logo
                sourceSize { width: 256; height: 256 }
                asynchronous: true
            }

            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.pixelSize: vpx(18)
                font.family: globalFonts.sans
                font.bold: true

                text: modelData.title
                color: "white"
                wrapMode: Text.Wrap

                visible: !assets.logo
            }
        }
    }
}