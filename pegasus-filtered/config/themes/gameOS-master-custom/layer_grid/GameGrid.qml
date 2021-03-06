import QtQuick 2.8
import QtMultimedia 5.9

FocusScope {
    id: root

    // Options
    property int numColumns: 4
    property alias gridWidth: grid.width
    property int gridItemSpacing: (numColumns == 4) ? vpx(7) : vpx(5) // it will double this
    property var gameCollection
    property var gameData
    property int currentGameIdx
    property string jumpToPattern: ''

    signal launchRequested
    signal menuRequested
    signal detailsRequested
    signal collectionNext
    signal collectionPrev
    signal gameChanged(int currentIdx)
    signal filterToggle

    Keys.onPressed: {
        if(event.isAutoRepeat)
            return;

        if(api.keys.isDetails(event)) {
            event.accepted = true;
            toggleFav(gameData);
            return;
        }

        if(api.keys.isCancel(event)) {
            event.accepted = true;
            menuRequested();
            return;
        }

        if(api.keys.isFilters(event)) {
            event.accepted = true;
            filterToggle();
            return;
        }
    }

    onCurrentGameIdxChanged: {
        grid.currentIndex = currentGameIdx
    }

    onGameCollectionChanged: {
        if (grid.currentIndex == -1) {
            grid.currentIndex = defaultGameIndex;
        }
    }

    GridView {
        id: grid
        focus: true
        anchors {
            top: parent.top
            topMargin: - gridItemSpacing
            bottom: parent.bottom
        }
        anchors.horizontalCenter: parent.horizontalCenter

        cellWidth: grid.width / numColumns
        cellHeight: (numColumns == 4) ? vpx(157) : vpx(210)

        preferredHighlightBegin: vpx(0)
        preferredHighlightEnd: vpx(314)
        highlightRangeMode: GridView.StrictlyEnforceRange
        displayMarginBeginning: 300
        cacheBuffer: 9000

        model: gameCollection
        onCurrentIndexChanged: {
            navSound.play();
            changeGameTimer.restart();
            return;
        }

        Timer {
            id: changeGameTimer
            running: true
            repeat: false
            interval: 200
            onTriggered: { gameChanged(grid.currentIndex); }
        }

        Component.onCompleted: {
            positionViewAtIndex(grid.currentIndex, GridView.Contain);
        }

        Keys.onPressed: {
            if(api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                root.detailsRequested()
            }

            if(api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
                event.accepted = true;
                var rows_to_skip = Math.max(1, Math.round(grid.height / cellHeight));
                var games_to_skip = rows_to_skip * numColumns;
                if (api.keys.isPageUp(event)) {
                    currentIndex = Math.max(currentIndex - games_to_skip, 0);
                } else {
                    currentIndex = Math.min(currentIndex + games_to_skip, model.count - 1);
                }
            } else if(event.key == Qt.Key_Home) {
                currentIndex = 0
            } else if(event.key == Qt.Key_End) {
                currentIndex = model.count  - 1
            }

            if(api.keys.isPrevPage(event)) {
                collectionPrev()
            }

            if(api.keys.isNextPage(event)) {
                collectionNext()
            }

            if(event.key == Qt.Key_Alt) { // single Alt key
                jumpToPattern = ''
            }

            if((event.modifiers & Qt.AltModifier) && event.text) {
                event.accepted = true;
                jumpToPattern += event.text.toLowerCase();
                var match = false;
                for (var idx = 0; idx < model.count; idx++) { // search title starting-with pattern
                    var lowTitle = model.get(idx).title.toLowerCase();
                    if (lowTitle.indexOf(jumpToPattern) == 0) {
                        currentIndex = idx;
                        match = true;
                        break;
                    }
                }
                if(!match) { // no match - try to search title containing pattern
                    for (var idx = 0; idx < model.count; idx++) {
                        var lowTitle = model.get(idx).title.toLowerCase();
                        if (lowTitle.indexOf(jumpToPattern) != -1) {
                            currentIndex = idx;
                            break;
                        }
                    }
                }
            }
        }

        delegate: GameGridItem {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            selected: GridView.isCurrentItem

            game: modelData
            collection: gameCollection
            z: (selected) ? 100 : 1

            onDetails: detailsRequested();
            onClicked: GridView.view.currentIndex = index
        }

        // Removal animation
        remove: Transition {
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 100
            }
        }
    }
}
