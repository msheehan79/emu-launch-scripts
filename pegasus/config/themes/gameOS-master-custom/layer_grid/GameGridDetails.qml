import QtQuick 2.8
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import "../utils.js" as Utils

Item {
    id: root

    property var gameData
    property var collectionData;
    property bool issteam: false
    property bool customCollection: customSystemLogoCategories.includes(currentCollection.summary)
    anchors.horizontalCenter: parent.horizontalCenter
    clip: true

    Text {
        id: gameTitle
        anchors {
            verticalCenter: parent.verticalCenter
        }
        width: vpx(850)
        text: gameData.title
        color: "white"
        font.pixelSize: vpx(70)
        font.family: titleFont.name
        font.bold: true
        elide: Text.ElideRight
    }

    DropShadow {
        anchors.fill: gameTitle
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8.0
        samples: 17
        color: "#ff000000"
        source: gameTitle
    }

    ColumnLayout {
        id: playinfo
        anchors {
            right: parent.right
            rightMargin: vpx(60)
            verticalCenter: parent.verticalCenter
        }
        width: vpx(150)
        spacing: vpx(4)

        Image {
            id: wreath
            source: (gameData.rating > 0.89) ? "../assets/images/wreath-gold.svg" : "../assets/images/wreath.svg"
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            smooth: true
            Layout.preferredWidth: vpx(100)
            Layout.preferredHeight: vpx(100)
            opacity: (gameData.rating != "") ? 1 : 0.3
            visible: !customCollection
            //visible: (gameData.rating != "") ? 1 : 0
            Layout.alignment: Qt.AlignCenter
            sourceSize.width: vpx(128)
            sourceSize.height: vpx(128)

            Text {
                id: metarating
                anchors {
                    top: parent.top
                    topMargin: vpx(20)
                }
                text: (gameData.rating == "") ? "NA" : Math.round(gameData.rating * 100)
                width: parent.width
                color: (gameData.rating > 0.89) ? "#FFCE00" : "white"
                font.pixelSize: vpx(45)
                font.family: globalFonts.condensed
                font.bold: true
                font.capitalization: Font.AllUppercase
                horizontalAlignment: Text.AlignHCenter
            }

            // DropShadow
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 0
                radius: 10.0
                samples: 17
                color: "#80000000"
                transparentBorder: true
            }
        }

        Text {
            id: ratingtext
            visible: !customCollection
            text: (gameData.rating == "") ? "No Rating" : "Rating"
            color: "white"
            font.pixelSize: vpx(16)
            font.family: globalFonts.condensed
            font.bold: true
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter
            Layout.topMargin: vpx(-12)
            Layout.preferredWidth: parent.width
        }

        // System logo for custom collections
        Image {
            id: systemlogo
            visible: customCollection
            source: "../assets/images/logos/" + Utils.getSystemTagName(gameData)
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            smooth: true
            Layout.preferredWidth: vpx(200)
            Layout.preferredHeight: vpx(50)
            Layout.alignment: Qt.AlignCenter
        }
    }

    RowLayout {
        id: metadata
        anchors {
            top: gameTitle.bottom
            topMargin: vpx(-5)
        }
        height: vpx(1)
        spacing: vpx(6)

        // Developer
        GameGridMetaBox {
            metatext: (gameData.developerList[0] != undefined) ? gameData.developerList[0] : "Unknown"
        }

        // Release year
        GameGridMetaBox {
            metatext: (gameData.release != "") ? gameData.release.getFullYear() : ""
        }

        // Players
        GameGridMetaBox {
            metatext: if(gameData.players > 1) {
                          gameData.players + " players"
                      } else {
                          gameData.players + " player"
                      }
        }

        // Genre
        GameGridMetaBox {
            metatext: (gameData.genreList[0] != undefined) ? gameData.genreList[0] : "Unknown"
        }

        // Spacer
        Item {
           Layout.preferredWidth: vpx(5)
        }

        Rectangle {
            id: spacer
            Layout.preferredWidth: vpx(2)
            Layout.fillHeight: true
            opacity: 0.5
        }

        Item {
            Layout.preferredWidth: vpx(5)
        }

        // Times played
        GameGridMetaBox {
            metatext: (gameData.playCount > 0) ? gameData.playCount + " times" : "Never played"
            icon: "../assets/images/gamepad.svg"
        }

        // Play time (if it has been played)
        GameGridMetaBox {
            metatext: Utils.formatPlayTime(gameData.playTime)
            icon: "../assets/images/clock.svg"
            visible: (gameData.playTime > 0)
        }
    }

}