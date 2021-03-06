import QtQuick 2.6
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.0

FocusScope {

    // Mental note - the ListView and the Collection are DIFFERENT
    property var collectionIndex: collectionAxis.currentIndex
    //property var currentCollection: api.collections.get(collectionIndex)
    property var currentCollection: allCollections[collectionIndex]

    property var gameIndex: collectionAxis.currentItem.axis.currentIndex
    property var currentGame: currentCollection.games.get(gameIndex)

    property var sourceIndex: null
    
    property var test: testing()

    function testing() {
        for(let i = 0; i < api.collections.count; i++) {
            console.log(api.collections.get(i));
        }
        console.log("Does this work?");
        return "test";
    }

    function getModel() {
        return api.collections.get(6).games;
    }

    // Create filter models for ALL collections then combine into an array for the model
    // Repeater? Instantiator?

    Repeater {
        model: api.collections
        Item {
            id: testingRpt
            SortFilterProxyModel {
                sourceModel: modelData.games
            }
        }
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: api.allGames
        filters: ValueFilter {
            roleName: "favorite"
            value: true
        }
    }

    SortFilterProxyModel {
        id: filteredGames1
        sourceModel: getModel()
    }

    property var newCollection: {
        return {
            name: "My Example Favorites",
            games: filteredGames
        }
    }

    property var newCollection1: {
        return {
            name: "My Example Favorites 1",
            games: filteredGames1
        }
    }

    property var allCollections: [newCollection, ...api.collections.toVarArray()]
    //property var allCollections: [newCollection, newCollection1]

    Image {
        id: screenshot

        asynchronous: true
        fillMode: Image.PreserveAspectFit

        source: currentGame.assets.screenshots[0] || ""
        sourceSize { width: 512; height: 512 }

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: vpx(-45)

        LinearGradient {
            width: parent.width * 0.25
            height: parent.height

            anchors.left: parent.left

            start: Qt.point(0, 0)
            end: Qt.point(width, 0)

            gradient: Gradient {
                GradientStop { position: 0.0; color: "black" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        LinearGradient {
            width: parent.width
            height: vpx(90)

            anchors.bottom: parent.bottom

            start: Qt.point(0, height)
            end: Qt.point(0, 0)

            gradient: Gradient {
                GradientStop { position: 0.0; color: "black" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    Text { 
        id: title

        text: currentGame.title
        color: "white"

        font.pixelSize: vpx(32)
        font.family: globalFonts.sans
        font.bold: true

        anchors.top: parent.top
        anchors.topMargin: vpx(42)
        anchors.left: parent.left
        anchors.leftMargin: vpx(100)
    }

    Row {
        id: detailsRow

        anchors.top: title.bottom
        anchors.topMargin: vpx(5)
        anchors.left: title.left

        spacing: vpx(10)

        Item {
            id: rating
            //visible: currentGame.rating > 0.0

            height: vpx(16)
            width: height * 5

            // Empty Stars
            Image {
                anchors.fill: parent

                source: "assets/star_empty.svg"
                sourceSize { width: parent.height; height: parent.height; }

                fillMode: Image.TileHorizontally
                horizontalAlignment: Image.AlignLeft
            }

            // Filled Stars
            Image {
                anchors.top: parent.top
                anchors.left: parent.left

                width: parent.width * currentGame.rating
                height: parent.height

                source: "assets/star_filled.svg"
                sourceSize { width: parent.height; height: parent.height; }

                fillMode: Image.TileHorizontally
                horizontalAlignment: Image.AlignLeft
            }
        }

        Text {
            id: year

            visible: currentGame.releaseYear > 0

            text: currentGame.releaseYear
            color: "white"
            font.pixelSize: vpx(16)
            font.family: globalFonts.sans
        }

        Rectangle {
            id: multiplayer

            width: smileys.width + vpx(8)
            height: smileys.height + vpx(5)

            color: "#555"
            radius: vpx(3)

            visible: currentGame.players > 1

            Image {
                id: smileys

                width: vpx(13) * currentGame.players
                height: vpx(13)

                anchors.centerIn: parent

                source: "assets/smiley.svg"
                sourceSize { width: smileys.height; height: smileys.height; }

                fillMode: Image.TileHorizontally
                horizontalAlignment: Image.AlignLeft
            }
        }

        Text {
            id: developer

            text: currentGame.developer
            color: "white"
            font.pixelSize: vpx(16)
            font.family: globalFonts.sans
        }
    }

    Text {
        id: description

        text: currentGame.description
        color: "white"
        font.pixelSize: vpx(18)
        font.family: globalFonts.sans

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignJustify
        elide: Text.ElideRight

        anchors {
            left: detailsRow.left
            right: parent.horizontalCenter
            top: detailsRow.bottom; topMargin: vpx(20)
            bottom: parent.verticalCenter; bottomMargin: vpx(32)
        }
    }

    PathView {
        id: collectionAxis

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.verticalCenter
        anchors.bottom: parent.bottom

        model: allCollections
        delegate: collectionAxisDelegate

        snapMode: PathView.SnapOneItem
        highlightRangeMode: PathView.StrictlyEnforceRange
        clip: true

        pathItemCount: 1 + Math.ceil(height / vpx(180))
        path: Path {
            startX: collectionAxis.width * 0.5
            startY: vpx(180) * -0.5
            PathLine {
                x: collectionAxis.path.startX
                y: collectionAxis.path.startY + collectionAxis.pathItemCount * vpx(180)
            }
        }
        preferredHighlightBegin: 1 / pathItemCount
        preferredHighlightEnd: preferredHighlightBegin

        focus: true
        Keys.onUpPressed: collectionAxis.decrementCurrentIndex()
        Keys.onDownPressed: collectionAxis.incrementCurrentIndex()
        Keys.onLeftPressed: currentItem.selectPrev()
        Keys.onRightPressed: currentItem.selectNext()
        Keys.onReturnPressed: currentItem.launchGame()
    }

    Component {
        id: collectionAxisDelegate

        Item {
            property alias axis: gameAxis

            function selectNext() {
                gameAxis.incrementCurrentIndex();
            }

            function selectPrev() {
                gameAxis.decrementCurrentIndex();
            }

            function launchGame() {
                //modelData.games.get(gameAxis.currentIndex).launch();
                //api.allGames.get(sourceIndex).launch();

                // Get the index of the game in the original source collection, then call that to launch it
                if(collectionAxis.currentIndex == 0) {
                    console.log('RECENT');
                    console.log(collectionAxis.currentIndex);
                    sourceIndex = modelData.games.mapToSource(gameAxis.currentIndex);
                    modelData.games.sourceModel.get(sourceIndex).launch();
                } else {
                    console.log('SYSTEMS');
                    sourceIndex = filteredGames.mapToSource(gameAxis.currentIndex);
                    modelData.games.get(sourceIndex).launch();
                }

                // For recent items
                //sourceIndex = modelData.games.mapToSource(gameAxis.currentIndex);
                //modelData.games.sourceModel.get(sourceIndex).launch();

                // For the rest
                //sourceIndex = filteredGames.mapToSource(gameAxis.currentIndex);
                //modelData.games.get(sourceIndex).launch();
            }

            SortFilterProxyModel {
                id: filteredGames
                sourceModel: modelData.games
            }

            width: PathView.view.width
            height: vpx(180)

            opacity: PathView.isCurrentItem ? 1.0 : 0.6
            Behavior on opacity { NumberAnimation { duration: 150 } }

            // Row Label
            Text {
                id: label

                text: modelData.name

                anchors.left: parent.left
                anchors.leftMargin: vpx(100)

                color: "white"
                font.pixelSize: vpx(18)
                font.family: globalFonts.sans
                font.bold: true

                height: vpx(45)
                verticalAlignment: Text.AlignVCenter
            }

            // Horizontal ListView
            PathView {
                id: gameAxis

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: label.bottom
                anchors.bottom: parent.bottom

                model: filteredGames
                delegate: GridImage {}

                snapMode: PathView.SnapOneItem
                highlightRangeMode: PathView.StrictlyEnforceRange

                pathItemCount: 2 + Math.ceil(width / vpx(250))
                path: Path {
                    startX: vpx(220) - vpx(250) * 2
                    startY: vpx(135) * 0.5
                    PathLine {
                        x: gameAxis.path.startX + gameAxis.pathItemCount * vpx(250)
                        y: gameAxis.path.startY
                    }
                }

                preferredHighlightBegin: 2 / pathItemCount
                preferredHighlightEnd: preferredHighlightBegin
            }
        }
    }

    Rectangle {
        id: selectionMarker

        width: vpx(240)
        height: vpx(135)

        color: "transparent"
        border { width: 3; color: "white" }

        anchors.left: parent.left
        anchors.leftMargin: vpx(100)
        anchors.top: parent.verticalCenter
        anchors.topMargin: vpx(45)
    }

}