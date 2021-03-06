import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import "../utils.js" as Utils

Rectangle {
    id: root
    property var collection
    property var backgroundcontainer

    color: "black"
    opacity: 0

    SequentialAnimation {
        id: switchanimation;
        OpacityAnimator {
            target: switchoverlay
            from: 0
            to: 0.95
            duration: 1
        }
        OpacityAnimator {
            target: logo
            from: 0
            to: 0.95
            duration: 100
        }
        PauseAnimation { duration: 300 }
        OpacityAnimator {
            target: switchoverlay
            from: 0.95
            to: 0
            duration: 300
        }
    }

    Image {
        id: logo
        anchors.centerIn: parent
        width: vpx(600)
        sourceSize {
            width: 512
            height: 512
        }
        source: "../assets/images/logos/" + collection.shortName
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        opacity: 0
    }

    Text {
        id: gameTitle
        anchors {
            top: parent.top
            topMargin: vpx(60)
        }
        width: parent.width
        text: Utils.formatCollectionName(collection)
        color: "white"
        font.pixelSize: vpx(70)
        font.family: titleFont.name
        font.bold: true
        font.capitalization: Font.AllUppercase
        anchors.centerIn: parent
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        visible: (logo.status == Image.Error)
    }

    onCollectionChanged: {
        logo.opacity = 0
        switchanimation.restart()
        switchanimation.running = true
    }

}
