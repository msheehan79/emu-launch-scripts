// vgOS Frontend

import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import SortFilterProxyModel 0.2
import "qrc:/qmlutils" as PegasusUtils
import "utils.js" as Utils
import "layer_grid"
import "layer_menu"
import "layer_details"

FocusScope {

    property bool menuactive: false
    property bool sorterActive: true
    property string sortField: 'sortTitle'

    property int categoryIndex: 0
    property int collectionIndex: 1
    property var currentCategory: collectionData[categoryIndex]
    property var currentCollection: collectionData[currentCategory][collectionIndex]

    property int currentGameIndex: 0
    readonly property var currentGame: findCurrentGameFromProxy(currentGameIndex, currentCollection)

    // Create a 2-level structure grouping collections by category (Summary field)
    property var collectionData: Utils.createCollectionHierarchy(lastPlayedCollection, favoritesCollection)

    SortFilterProxyModel {
        id: lastPlayedFilter
        sourceModel: api.allGames
        sorters: RoleSorter {
            roleName: "lastPlayed"
            sortOrder: Qt.DescendingOrder
        }
    }

    SortFilterProxyModel {
        id: lastPlayedGames
        sourceModel: lastPlayedFilter
        filters: IndexFilter {
            maximumIndex: 51
        }
    }

    SortFilterProxyModel {
        id: favoriteGames
        sourceModel: api.allGames
        filters: ValueFilter {
            roleName: "favorite"
            value: true
        }
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: currentCollection.games
        sorters: [
            //RoleSorter {
            //    roleName: sortField
            //    sortOrder: Qt.DescendingOrder
            //    enabled: sorterActive
            //},
            ExpressionSorter {
                expression: {
                    var sortLeft = getCollectionSortTag(modelLeft, currentCollection.shortName);
                    var sortRight = getCollectionSortTag(modelRight, currentCollection.shortName);
                    return (sortLeft < sortRight);
                }
                enabled: currentCollection.summary == "Custom"
            }
        ]
    }

    property var favoritesCollection: {
        return {
            name: "Favorites",
            shortName: "favorites",
            summary: "Favorites",
            games: favoriteGames
        }
    }

    property var lastPlayedCollection: {
        return {
            name: "Last Played",
            shortName: "lastplayed",
            summary: "Last Played",
            games: lastPlayedGames
        }
    }

    // Loading the fonts here makes them usable in the rest of the theme
    // and can be referred to using their name and weight.
    FontLoader { id: titleFont; source: "fonts/AkzidenzGrotesk-BoldCond.otf" }
    FontLoader { id: subtitleFont; source: "fonts/Gotham-Bold.otf" }

    //////////////////////////
    // Collection switching //

    function modulo(a, n) {
        return (a % n + n) % n;
    }

    function nextCollection() {
        if((collectionIndex + 1) == collectionData[currentCategory].length) {
            jumpToCollection(0);
        } else {
            jumpToCollection(collectionIndex + 1);
        }
    }

    function prevCollection() {
        if((collectionIndex - 1) == -1) {
            jumpToCollection(collectionData[currentCategory].length - 1);
        } else {
            jumpToCollection(collectionIndex - 1);
        }
    }

    function jumpToCollection(idx) {
        api.memory.set('gameCollIndex-' + categoryIndex + '-' + collectionIndex, currentGameIndex); // save game index of current collection

        categoryIndex = platformmenu.catList.currentIndex; // set new collection category
        api.memory.set('categoryIndex', categoryIndex); // save category index of current collection

        collectionIndex = modulo(idx, (api.collections.count + 2)); // new collection index

        currentGameIndex = api.memory.get('gameCollIndex-' + categoryIndex + '-' + collectionIndex) || 0; // restore game index for newly selected collection
        api.memory.set('collectionIndex', collectionIndex); //save the new collection index.
    }

    // End collection switching //
    //////////////////////////////

    ////////////////////
    // Game switching //

    function findCurrentGameFromProxy(idx, collection) {
        // Last Played collection uses 2 filters chained together
        if(collection.name == "Last Played") {
            currentCollection.games.count;
            return api.allGames.get(lastPlayedFilter.mapToSource(idx));
        } else if(collection.name == "Favorites") {
            // not sure why but if this isnt here the game metadata is blank when favorites first selected - may have to do with collections not being ready?
            currentCollection.games.count;
            return api.allGames.get(favoriteGames.mapToSource(idx));
        } else {
            return currentCollection.games.get(filteredGames.mapToSource(idx));
        }
    }

    function changeGameIndex(idx) {
        currentGameIndex = idx
        if(collectionIndex && idx) {
            api.memory.set('gameCollIndex-' + categoryIndex + '-' + collectionIndex, idx);
        }
    }

    // End game switching //
    ////////////////////////

    ////////////////////
    // Game sorting //

    function getCollectionSortTag(gameData, collName) {
        const matches = gameData.tagList.filter(s => s.includes('CustomSort:' + collName + ':'));
        return matches.length == 0 ? "" : matches[0].replace("CustomSort:" + collName + ':', "");
    }

    function changeSortField() {
        if(sortField == 'sortTitle') {
            sortField = 'release';
        } else {
            sortField = 'sortTitle';
        }
    }

    // End game sorting //
    ////////////////////////

    ////////////////////
    // Launching game //

    // The default collection is Last Played (index 1) - index 0 is the 'Back' pseudo collection
    Component.onCompleted: {
        categoryIndex = api.memory.get('categoryIndex') || 0;
        collectionIndex = api.memory.get('collectionIndex') || 1;
        currentGameIndex = api.memory.get('gameCollIndex-' + categoryIndex + '-' + collectionIndex) || 0;
    }

    // Store info on the current category, collection & game index to API memory before launching
    // For Last Played, we always want to return to the first game in the collection so it is the one that just ended
    function launchGame() {
        api.memory.set('categoryIndex', categoryIndex);
        api.memory.set('collectionIndex', collectionIndex);   
        api.memory.set('gameCollIndex-' + categoryIndex + '-' + collectionIndex, currentCollection.name == "Last Played" ? 0 : currentGameIndex);
        currentGame.launch();
    }

    // End launching game //
    ////////////////////////

    function toggleMenu() {
        if(platformmenu.catList.focus || platformmenu.collList.focus) {
            // Close the menu
            gamegrid.focus = true
            platformmenu.outro()
            content.opacity = 1
            contentcontainer.opacity = 1
            contentcontainer.x = 0
            collectiontitle.opacity = 1
        } else {
            // Open the menu
            platformmenu.collList.focus = true
            platformmenu.collList.visible = true
            platformmenu.catList.visible = false
            platformmenu.intro()
            content.opacity = 0.3
            contentcontainer.opacity = 0.3
            contentcontainer.x = platformmenu.menuwidth
            collectiontitle.opacity = 0
        }
    }

    function toggleDetails() {
        if(gamedetails.active) {
            // Close the details
            gamegrid.focus = true
            gamegrid.visible = true
            content.opacity = 1
            backgroundimage.dimopacity = 0.97
            gamedetails.active = false
            gamedetails.outro()
        } else {
            // Open details panel
            gamedetails.focus = true
            gamedetails.active = true
            gamegrid.visible = false
            content.opacity = 0
            backgroundimage.dimopacity = 0
            gamedetails.intro()
        }
    }

    Item {
        id: everythingcontainer
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        BackgroundImage {
            id: backgroundimage
            gameData: currentGame
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
        }

        Image {
            id: platformlogo
            source: "assets/images/logos/" + currentCollection.shortName
            fillMode: Image.PreserveAspectFit
            height: vpx(60)
            width: parent.width
            anchors { 
                top: parent.top
                topMargin: vpx(16)
                horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            id: platformName
            text: Utils.formatCollectionName(currentCollection)
            width: parent.width
            color: "white"
            font.pixelSize: vpx(35)
            font.family: titleFont.name
            font.bold: false
            elide: Text.ElideRight
            anchors { 
                top: parent.top
                topMargin: vpx(16)
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            visible: (platformlogo.status == Image.Error)
        }

        Item {
            id: contentcontainer
            width: parent.width
            height: parent.height
            
            Behavior on x {
                PropertyAnimation {
                    duration: 300
                    easing.type: Easing.OutQuart
                    easing.amplitude: 2.0
                    easing.period: 1.5
                }
            }

            Image {
                id: menuicon
                source: "assets/images/menuicon.svg"
                width: vpx(24)
                height: vpx(24)
                anchors { 
                    top: parent.top
                    topMargin: vpx(32)
                    left: parent.left
                    leftMargin: vpx(32)
                }
                visible: gamegrid.focus
            }

            Text {
                id: collectiontitle
                width: parent.width
                anchors {
                    top: parent.top
                    topMargin: vpx(35)
                    left: menuicon.right
                    leftMargin: vpx(35)
                }

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
        
                color: "white"
                font.pixelSize: vpx(16)
                font.family: globalFonts.sans
                elide: Text.ElideRight

                // DropShadow
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 8.0
                    samples: 17
                    color: "#80000000"
                    transparentBorder: true
                }
            }

            // Game details
            GameGridDetails {
                id: content
                gameData: currentGame
                collectionData: currentCollection

                width: parent.width - vpx(182)
                height: vpx(200)
                anchors {
                    top: menuicon.bottom
                    topMargin: vpx(-20)
                }

                // Text doesn't look so good blurred so fade it out when blurring
                opacity: 1
                Behavior on opacity {
                    OpacityAnimator { duration: 100 }
                }
            }

            // Game grid
            Item {
                id: gridcontainer
                clip: true

                width: parent.width
                anchors {
                    top: content.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                GameGrid {
                    id: gamegrid
                    gameCollection: filteredGames
                    gameData: currentGame
                    currentGameIdx: currentGameIndex

                    height: parent.height
                    anchors {
                        top: parent.top
                        topMargin: vpx(10)
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }

                    focus: true
                    Behavior on opacity {
                        OpacityAnimator { duration: 100 }
                    }
                    gridWidth: parent.width - vpx(164)

                    onLaunchRequested: launchGame()
                    onCollectionNext: nextCollection()
                    onCollectionPrev: prevCollection()
                    onMenuRequested: toggleMenu()
                    onDetailsRequested: toggleDetails()
                    onGameChanged: changeGameIndex(currentIdx)
                    onFilterToggle: changeSortField()
                }
            }

            GameDetails {
                id: gamedetails
                gameData: currentGame
                property bool active: false

                width: parent.width
                height: parent.height
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                onDetailsCloseRequested: toggleDetails()
                onLaunchRequested: launchGame()
            }
        }

    }

    PlatformMenu {
        id: platformmenu
        collection: currentCollection
        categoryIdx: categoryIndex
        collectionIdx: collectionIndex
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height
        backgroundcontainer: everythingcontainer
        onMenuCloseRequested: toggleMenu()
        onSwitchCollection: jumpToCollection(collectionIdx)
    }

    // Switch collection overlay
    GameGridSwitcher {
        id: switchoverlay
        collection: currentCollection
        anchors.fill: parent
        width: parent.width
        height: parent.height
    }

    // Empty area for swiping on touch
    Item {
        anchors { 
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: vpx(75)
        PegasusUtils.HorizontalSwipeArea {
            anchors.fill: parent
            visible: gamegrid.focus
            onSwipeRight: toggleMenu()
            onClicked: toggleMenu()
        }
    }

    ///////////////////
    // SOUND EFFECTS //
    ///////////////////
    SoundEffect {
        id: navSound
        source: "assets/audio/tap-mellow.wav"
        volume: 1.0
    }

    SoundEffect {
        id: menuIntroSound
        source: "assets/audio/slide-scissors.wav"
        volume: 1.0
    }

    SoundEffect {
        id: toggleSound
        source: "assets/audio/tap-sizzle.wav"
        volume: 1.0
    }

}
