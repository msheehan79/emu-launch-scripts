import QtQuick 2.8
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import "qrc:/qmlutils" as PegasusUtils
import "../Global"

FocusScope {
    focus: games.focus

    property int sortIndex: api.memory.get('sortIndex') || 0
    readonly property var sortFields: ['sortTitle', 'release', 'rating', 'genre', 'lastPlayed', 'favorite']
    readonly property var sortLabels: {'sortTitle':'Title', 'release':'Release Date', 'rating':'Rating', 'genre':'Genre', 'lastPlayed':'Last Played', 'favorite':'Favorite'}
    readonly property string sortField: sortFields[sortIndex]
    readonly property var customSortCategories: ['Custom', 'Series']
    readonly property var customSystemLogoCategories: ['Custom', 'Series']
    readonly property bool customCollection: customSystemLogoCategories.includes(currentCollection.summary)

    property var shortname: clearShortname(currentCollection.shortName)

    state: "all"

    property int currentGameIndex: 0
    property var currentGame: {
        if (gv_games.count === 0)
            return null;
        return currentCollection.games.get(filteredGames.mapToSource(currentGameIndex))
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: currentCollection.games
        sorters: [
            RoleSorter {
                roleName: sortField
                sortOrder: sortField == 'rating' || sortField == 'lastPlayed' || sortField == 'favorite' ? Qt.DescendingOrder : Qt.AscendingOrder
                //enabled: !customSortCategories.includes(currentCollection.summary)
                enabled: true
            },
            ExpressionSorter {
                expression: {
                    if(!customSortCategories.includes(currentCollection.summary)) {
                        return true;
                    }

                    var sortLeft = getCollectionSortTag(modelLeft, currentCollection.shortName);
                    var sortRight = getCollectionSortTag(modelRight, currentCollection.shortName);
                    return (sortLeft < sortRight);
                }
                //enabled: customSortCategories.includes(currentCollection.summary)
                enabled: false
            }
        ]
    }

    Behavior on focus {
        ParallelAnimation {
            PropertyAnimation {
                target: skew_color
                property: "anchors.leftMargin"
                from: parent.width * 0.97
                to: parent.width * 0.77
                duration: 250
            }
        }
    }

    Rectangle {
        id: skew_color
        readonly property var touch_color: (dataConsoles[shortname] !== undefined) ? dataConsoles[shortname].color : dataConsoles["default"].color
        width: parent.width * 0.42
        height: parent.height
        antialiasing: true
        anchors {
            left: parent.left; leftMargin: parent.width * 0.77
        }
        color: touch_color
        Behavior on color {
            ColorAnimation { duration: 250; }
        }

        transform: Matrix4x4 {
            property real a: 12 * Math.PI / 180
            matrix: Qt.matrix4x4(
                1,      -Math.tan(a),       0,      0,
                0,      1,                  0,      0,
                0,      0,                  1,      0,
                0,      0,                  0,      1
            )
        }
    }

    // Game details
    Item {
        id: item_game_details
        width: parent.width * 0.75
        anchors {
            top: parent.top
            bottom: games_bottom.top
            horizontalCenter: parent.horizontalCenter
        }

        Item {
            anchors.fill: parent

            // ALL GAMES INFORMATION
            Component {
                id: cpnt_gameList_details

                Item {
                    readonly property var currentGameGenre: currentGame.genre.split(" / ") || ""
                    anchors.fill: parent

                    // RELEASE DATE
                    Text {
                        id: txt_releaseYear
                        anchors {
                            top: parent.top; topMargin: -vpx(45)
                        }

                        text: currentGame.releaseYear || "N/A"
                        font {
                            family: global.fonts.sans
                            weight: Font.Black
                            italic: true
                            pixelSize: vpx(140)
                        }
                        color: "#F0F0F0"

                        Behavior on text {
                            PropertyAnimation {
                                target: txt_releaseYear
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 600
                                easing.type: Easing.OutExpo
                            }
                        }

                    }

                    // RATING
                    RatingStars {
                        id: ratingSection
                        readonly property var rating: (currentGame.rating *5).toFixed(1)
                        anchors {
                            top: parent.top; topMargin: parent.height * 0.1
                            right: parent.right
                        }
                    }

                    // TITLE + DEVELOPER + PLAYERS + GENRES + DESCRIPTION
                    Column {
                        spacing: vpx(10)
                        width: parent.width
                        anchors {
                            bottom: parent.bottom; bottomMargin: vpx(20)
                        }

                        Text {
                            width: parent.width
                            text: currentGame.title
                            elide: Text.ElideRight
                            font {
                                family: robotoSlabRegular.name
                                pixelSize: vpx(32)
                            }
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                            color: "black"
                        }

                        Row {
                            spacing: vpx(5)

                            Text {
                                text: "Developed by"
                                font {
                                    family: global.fonts.sans
                                    weight: Font.Light
                                    italic: true
                                    pixelSize: vpx(14)
                                }
                                color: "black"
                            }

                            Text {
                                text: currentGame.developer
                                font {
                                    family: global.fonts.sans
                                    weight: Font.Medium
                                    pixelSize: vpx(14)
                                }
                                color: "black"
                            }

                            Text {
                                text: "for"
                                font {
                                    family: global.fonts.sans
                                    weight: Font.Light
                                    italic: true
                                    pixelSize: vpx(14)
                                }
                                color: "black"
                                visible: customCollection
                            }

                            Text {
                                text: dataConsoles[getSystemTagName(currentGame)].fullName
                                font {
                                    family: global.fonts.sans
                                    weight: Font.Medium
                                    pixelSize: vpx(14)
                                }
                                color: "black"
                                visible: customCollection
                            }

                        }

                        Row {
                            spacing: vpx(10)

                            Rectangle {
                                width: txt_players.contentWidth + vpx(20)
                                height: txt_players.contentHeight + vpx(10)
                                color: "black"
                                border {
                                    width: vpx(1)
                                    color: "black"
                                }

                                Text {
                                    id: txt_players
                                    property var convertPlayer: currentGame.players > 1 ? "1-"+currentGame.players+" PLAYERS" : "1 PLAYER"
                                    anchors.centerIn: parent
                                    text: convertPlayer
                                    font {
                                        family: global.fonts.sans
                                        weight: Font.Black
                                        pixelSize: vpx(12)
                                    }
                                    color: "white"
                                }
                            }

                            Rectangle {
                                width: txt_favorited.contentWidth + vpx(20)
                                height: txt_favorited.contentHeight + vpx(10)
                                color: "#ED3496"

                                Text {
                                    id: txt_favorited
                                    anchors.centerIn: parent
                                    text: "FAVORITED"
                                    font {
                                        family: global.fonts.sans
                                        weight: Font.Black
                                        pixelSize: vpx(12)
                                    }
                                    color: "white"
                                }
                                visible: currentGame.favorite
                            }

                            Repeater {
                                model: currentGameGenre
                                delegate: Rectangle {
                                    width: txt_genre.contentWidth + vpx(20)
                                    height: txt_genre.contentHeight + vpx(10)
                                    color: "white"
                                    border {
                                        width: vpx(1)
                                        color: "black"
                                    }

                                    Text {
                                        id: txt_genre
                                        anchors.centerIn: parent
                                        text: modelData
                                        font {
                                            family: global.fonts.sans
                                            weight: Font.Medium
                                            pixelSize: vpx(12)
                                        }
                                        color: "black"
                                    }
                                    visible: (modelData !== "")
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: vpx(69)
                            // anchors.bottom: parent.bottom

                            PegasusUtils.AutoScroll {
                                anchors.fill: parent
                                Text {
                                    id: txt_game_description
                                    width: parent.width
                                    text: (currentGame.description || currentGame.summary) ? (currentGame.description || currentGame.summary) : "No description."
                                    font {
                                        family: global.fonts.condensed
                                        weight: Font.Light
                                        pixelSize: vpx(14)
                                    }
                                    wrapMode: Text.WordWrap
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignJustify
                                    color: "black"
                                }
                            }
                        }


                    }
                }

            }

            Loader {
                id: loader_gameList_details
                width: parent.width * 0.67
                height: parent.height
                asynchronous: true
                sourceComponent: cpnt_gameList_details
                active: games.focus && currentGame !== null
                visible: status === Loader.Ready
            }

            // BOX ART
            Item {
                width: parent.width * 0.3
                height: parent.height
                anchors {
                    right: parent.right
                }

                Item {
                    id: item_game_boxart
                    width: parent.width
                    height: parent.height * 0.85
                    anchors.verticalCenter: parent.verticalCenter

                    Component {
                        id: cpnt_game_boxart

                        Item {
                            anchors.fill: parent

                            Rectangle {
                                id: rect_boxart
                                width: img_game_boxart.paintedWidth + vpx(15)
                                height: img_game_boxart.paintedHeight + vpx(15)
                                anchors.centerIn: img_game_boxart
                                color: "white"
                            }

                            DropShadow {
                                anchors.fill: rect_boxart
                                horizontalOffset: 0
                                verticalOffset: vpx(5)
                                radius: 24
                                samples: 22
                                spread: 0.2
                                color: "#35000000"
                                source: rect_boxart
                            }

                            Image {
                                id: img_game_boxart
                                source: currentGame.assets.boxFront || currentGame.assets.logo
                                anchors {
                                    fill: parent
                                }
                                fillMode: Image.PreserveAspectFit
                                horizontalAlignment: Image.AlignHCenter
                                verticalAlignment: Image.AlignVCenter
                                asynchronous: true

                                Behavior on source {
                                    PropertyAnimation {
                                        target: img_game_boxart
                                        property: "opacity"
                                        from: 0
                                        to: 1
                                        duration: 600
                                        easing.type: Easing.OutExpo
                                    }
                                }
                            }
                        }
                    }

                    Loader {
                        id: loader_game_boxart
                        anchors.fill: parent
                        asynchronous: true
                        sourceComponent: cpnt_game_boxart
                        active: games.focus && currentGame !== null
                        visible: status === Loader.Ready
                    }

                }
            }

        }

        visible: currentGame !== null
    }

    Text {
        anchors.centerIn: parent
        text: "No favorites."
        font {
            family: robotoSlabRegular.name
            pixelSize: vpx(42)
        }
        visible: currentGame === null && (games.state === "favorites")
    }

    Item {
        id: games_bottom
        width: parent.width
        height: parent.height * 0.51
        anchors {
            bottom: parent.bottom
        }

        GridView {
            id: gv_games
            width: parent.width * 0.77
            height: vpx(260)
            cellWidth: width /5
            cellHeight: height /2
            anchors.horizontalCenter: parent.horizontalCenter

            clip: true

            preferredHighlightBegin: height * 0.5
            preferredHighlightEnd: height * 0.5

            currentIndex: currentGameIndex
            onCurrentIndexChanged: currentGameIndex = currentIndex

            model: filteredGames
            delegate: Item {
                property bool isCurrentItem: GridView.isCurrentItem
                property bool isFocused: games.focus
                property bool doubleFocus: isFocused && isCurrentItem

                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                Item {
                    anchors {
                        fill: parent
                        margins: vpx(5)
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#E5E5E5"
                        visible: !loader_gameList_game.visible
                    }

                    Loader {
                        id: loader_gameList_game
                        anchors.fill: parent

                        asynchronous: true
                        sourceComponent: GameItem {}
                        active: games.focus
                        visible: status === Loader.Ready
                    }
                }
            }

            highlightRangeMode: GridView.ApplyRange
            snapMode: GridView.NoSnap

            focus: games.focus

            Component.onCompleted: {
                currentGameIndex = api.memory.get(collectionType + "-" + currentCollectionIndex + "-currentGameIndex") || 0
                positionViewAtIndex(currentGameIndex, GridView.SnapPosition)
            }

            Keys.onPressed: {

                if (api.keys.isAccept(event)) {
                    event.accepted = true;
                    if (currentGame !== null) {
                        saveCurrentState(currentGameIndex, sortIndex)
                        currentGame.launch()
                    }

                }

                if (api.keys.isFilters(event)) {
                    event.accepted = true;
                    sortIndex = (sortIndex + 1) % sortFields.length;
                }

                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    currentMenuIndex = 1
                }

                if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    if (currentGame !== null) {
                        currentGame.favorite = !currentGame.favorite
                    }

                }

                if (api.keys.isPageDown(event)) {
                    event.accepted = true;

                    if (currentCollectionIndex <= 0)
                        currentCollectionIndex = api.collections.count - 1
                    else
                        currentCollectionIndex--;

                    saveCurrentState(currentGameIndex, sortIndex)
                    currentGameIndex = 0
                }

                if (api.keys.isPageUp(event)) {
                    event.accepted = true;

                    if (currentCollectionIndex >= api.collections.count - 1) {
                        currentCollectionIndex = 0;
                    }
                    else {
                        currentCollectionIndex++;
                    }

                    saveCurrentState(currentGameIndex, sortIndex)
                    currentGameIndex = 0
                }

            }

        }

        Component {
            id: cpnt_helper_nav

            Item {
                anchors.fill: parent

                Rectangle {
                    property int heightBar: parent.height - vpx(50)
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top; topMargin: vpx(8)
                    }
                    width: vpx(2)
                    height: heightBar * ( (currentGameIndex + 1) / gv_games.count )
                    color: "#F0F0F0"
                }

                Text {
                    id: helper_count
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom; bottomMargin: vpx(6)
                    }
                    text: (currentGameIndex + 1)+"/"+gv_games.count
                    font {
                        family: robotoSlabLight.name
                        pixelSize: vpx(14)
                    }

                }
            }
        }

        Loader {
            id: loader_helper_nav
            width: vpx(50)
            height: gv_games.height
            anchors {
                right: gv_games.left; rightMargin: vpx(25)
                top: gv_games.top;
            }
            asynchronous: true
            sourceComponent: cpnt_helper_nav
            active: games.focus && currentGame !== null
            visible: status === Loader.Ready
        }

    }

    Row {
        anchors {
            bottom: parent.bottom; bottomMargin: vpx(15)
            left: parent.left; leftMargin: parent.width * 0.15
        }
        spacing: vpx(150)

        Controls {
            id: button_B

            message: "GO <b>BACK</b>"

            text_color: "black"
            front_color: "#E6140D"
            back_color: "white"
            input_button: "B"
        }

        Controls {
            id: button_X

            message: currentGame.favorite ? "REMOVE <b>FAVORITE</b>" : "ADD <b>FAVORITE</b>"

            text_color: "white"
            front_color: "#1C2C98"
            back_color: "#1C2C98"
            input_button: "X_reverse"

            visible: currentGame !== null
        }

        Controls {
            id: button_Y

            message: "SORTED BY <b>" + getSortLabel() + "</b>";

            text_color: "black"
            front_color: "#FDB200"
            back_color: "white"
            input_button: "Y"
        }
    }

    function getCollectionSortTag(gameData, collName) {
        const matches = gameData.tagList.filter(s => s.includes('CustomSort:' + collName + ':'));
        return matches.length == 0 ? "" : matches[0].replace("CustomSort:" + collName + ':', "");
    }

    function getSortLabel() {
        if (currentCollection.shortName == 'lastplayed') {
            return 'Last Played';
        //} else if (customSortCategories.includes(currentCollection.summary)) {
        //    return 'Custom';
        } else {
            return sortLabels[sortField];
        }
    }

    // Returns the System tag name for a game, if present
    function getSystemTagName(gameData) {
        const matches = gameData.tagList.filter(s => s.includes('System:'));
        return matches.length == 0 ? "" : matches[0].replace("System:", "");
    }

}