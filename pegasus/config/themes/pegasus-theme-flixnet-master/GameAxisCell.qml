// Pegasus Frontend - Flixnet theme
// Copyright (C) 2017  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.7


Item {
    property var game

    Rectangle {
        anchors.fill: parent
        color: "#333"
        visible: image.status !== Image.Ready

        Image {
            anchors.centerIn: parent

            visible: image.status === Image.Loading
            source: "qrc:/common/loading-spinner.png"

            RotationAnimator on rotation {
                loops: Animator.Infinite
                from: 0; to: 360
                duration: 500
            }
        }

        Text {
            text: model.title

            width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            anchors.centerIn: parent
            visible: !model.assets.gridicon

            color: "#eee"
            font {
                pixelSize: vpx(16)
                family: globalFonts.sans
            }
        }
    }

    Image {
        id: image

        anchors.fill: parent
        visible: source

        asynchronous: true
        fillMode: Image.PreserveAspectCrop

        source: assets.banner || (assets.screenshots && assets.screenshots[0]) || assets.boxFront || assets.steam
        sourceSize { width: 256; height: 256 }

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
