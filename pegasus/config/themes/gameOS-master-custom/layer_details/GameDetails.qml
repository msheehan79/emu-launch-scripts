import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQuick.Layouts 1.11
import "qrc:/qmlutils" as PegasusUtils
import "../layer_grid"
import "../utils.js" as Utils

Item {
    id: root

    property var gameData
    property bool isSteam: false
    property int padding: vpx(50)
    property int cornerradius: vpx(8)
    property bool showVideo: false
    property bool boxAvailable: gameData.assets.boxFront
    property int videooffset: vpx(330)
    property int numbuttons: (gameData.assets.videos.length) ? 4 : 3

    signal launchRequested
    signal detailsCloseRequested
    signal filtersRequested
    signal switchCollection(int collectionIdx)

    onFocusChanged: {
        if (focus) {
            launchBtn.focus = true
        }
    }

    visible: (backgroundbox.opacity == 0) ? false : true

    // Empty area for closing out of bounds
    Item {
        anchors.fill: parent
        PegasusUtils.HorizontalSwipeArea {
            anchors.fill: parent
            onClicked: closedetails()
        }
    }

    Keys.onPressed: {
        if(event.isAutoRepeat) {
            return;
        }

        if(api.keys.isAccept(event)) {
            event.accepted = true;
            root.launchRequested();
            return;
        }

        if(api.keys.isDetails(event)) {
            event.accepted = true;
<<<<<<< HEAD
            toggleFav(gameData);
=======
            if (gameData) {
                gameData.favorite = !gameData.favorite;
            }
            toggleSound.play();
>>>>>>> parent of 3b226fa... Add support for "Playing" dynamic collection that can be updated from within the frontend. Also add count of games to the platform menu.
            return;
        }

        if(api.keys.isCancel(event)) {
            event.accepted = true;
            closedetails();
            return;
        }

        if(api.keys.isNextPage(event) || api.keys.isPrevPage(event)) {
            event.accepted = true;
            return;
        }

        if(api.keys.isPageDown(event) || api.keys.isPageUp(event)) {
            event.accepted = true;
            toggleVideo();
            return;
        }
    }

    Timer {
        id: videoDelay
        interval: 100
        onTriggered: {
            if (gameData.assets.videos.length) {
                videoPreviewLoader.sourceComponent = videoPreviewWrapper;
                fadescreenshot.restart();
            }
        }
    }

    Timer {
        id: fadescreenshot
        interval: 500
        onTriggered: {
            screenshot.opacity = 0;
        }
    }

    function toggleVideo() {
        if (gameData.assets.videos.length && (boxart.opacity == 0 || boxart.opacity == 1)) {
            if (showVideo) {
                // BOXART
                showVideo = false;
                boxart.x = boxart.x + videooffset;
                boxart.opacity = 1;
                details.anchors.rightMargin = 0;
                bgGradient.width = bgGradient.parent.width;
                videoPreviewLoader.sourceComponent = undefined;
                fadescreenshot.stop();
                screenshot.opacity = 1;
            } else {
                // VIDEO
                showVideo = true;
                boxart.x = boxart.x - videooffset;
                boxart.opacity = 0;
                details.anchors.rightMargin = videooffset;
                bgGradient.width = bgGradient.width / 20;
                videoDelay.restart();
                menuIntroSound.play();
            }
        }
    }

    function closedetails() {
        if (showVideo) {
            toggleVideo();
        }
        detailsCloseRequested();
    }

    Rectangle {
        id: backgroundbox
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: parent.width - vpx(182)
        height: boxAvailable ? boxart.height + (padding*2) + navigationbox.height : vpx(400)
        color: "#1a1a1a"
        radius: cornerradius
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
        scale: 1.03
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        // DropShadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: 20.0
            samples: 17
            color: "#80000000"
            transparentBorder: true
        }

        // Background art
        Item {
            id: bgart
            anchors.right: parent.right
            width: vpx(500)
            height: parent.height - navigationbox.height

            // Video preview
            Component {
                id: videoPreviewWrapper
                Video {
                    source: gameData.assets.videos.length ? gameData.assets.videos[0] : ""
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectCrop
                    muted: false
                    loops: MediaPlayer.Infinite
                    autoPlay: true
                }
            }

            // Video
            Loader {
                id: videoPreviewLoader
                asynchronous: true
                anchors {
                    fill: parent
                }
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: videoPreviewLoader.width
                        height: videoPreviewLoader.height

                        Rectangle {
                            anchors.centerIn: parent
                            width: videoPreviewLoader.width
                            height: videoPreviewLoader.height
                            radius: cornerradius - vpx(1)
                        }
                    }
                }
            }

            // Screenshot
            Image {
                id: screenshot
                anchors {
                    top: parent.top;
                    verticalCenter: parent.verticalCenter
                }
                width: parent.width
                height: parent.height
                source: gameData.assets.screenshots[0] || ""
                fillMode: Image.PreserveAspectCrop
                Behavior on opacity {
                    NumberAnimation { duration: 500 }
                }
            }

            // Fade off
            LinearGradient {
                id: bgGradient
                z: parent.z + 1
                width: parent.width
                height: parent.height
                Behavior on width {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InQuad
                    }
                }
                start: Qt.point(width, 0)
                end: Qt.point(0, 0)
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#001a1a1a"
                    }
                    GradientStop {
                        position: 1
                        color: "#ff1a1a1a"
                    }
                }
                transform: Scale { xScale: 10.0 }
            }

            // Round those corners!
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: backgroundbox.width
                    height: backgroundbox.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: backgroundbox.width
                        height: backgroundbox.height
                        radius: cornerradius
                    }
                }
            }
        }

        Item {
            id: infobox
            anchors {
                fill: parent
                margins: padding
            }
            width: parent.width
            height: parent.height

            // NOTE: Boxart
            Image {
                id: boxart
                width: vpx(300)
                source: gameData.assets.boxFront
                sourceSize {
                    width: vpx(512)
                    height: vpx(512)
                }
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: gameData.assets.boxFront || ""
                smooth: true
                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
                Behavior on x {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InQuad
                    }
                }

                // Favourite tag
                Item {
                    id: favetag
                    anchors { fill: parent }
                    opacity: gameData.favorite ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }

                    Image {
                        id: favebg
                        anchors {
                            top: parent.top
                            topMargin: vpx(0)
                            right: parent.right
                            rightMargin: vpx(0)
                        }
                        source: "../assets/images/favebg.svg"
                        width: vpx(32)
                        height: vpx(32)
                        sourceSize {
                            width: vpx(32)
                            height: vpx(32)
                        }
                        visible: false
                    }
                    
                    ColorOverlay {
                        anchors.fill: favebg
                        source: favebg
                        color: "#FF9E12"
                        z: 10
                    }

                    Image {
                        id: star
                        anchors {
                            top: parent.top
                            topMargin: vpx(3)
                            right: parent.right
                            rightMargin: vpx(3)
                        }
                        width: vpx(13)
                        height: vpx(13)
                        source: "../assets/images/star.svg"
                        sourceSize {
                            width: vpx(32)
                            height: vpx(32)
                        }
                        smooth: true
                        z: 11
                    }

                    z: 12
                }

                // Round the corners
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: boxart.width
                        height: boxart.height

                        Rectangle {
                            anchors.centerIn: parent
                            width: boxart.width
                            height: boxart.height
                            radius: vpx(3)
                        }
                    }
                }
            }

            // NOTE: Details section
            Item {
                id: details
                anchors {
                    top: parent.top
                    topMargin: vpx(0)
                    left: boxAvailable ? boxart.right : parent.left
                    leftMargin: boxAvailable ? vpx(30) : vpx(5)
                    bottom: parent.bottom
                    right: parent.right
                }
                Behavior on anchors.rightMargin {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InQuad
                    }
                }

                Text {
                    id: gameTitle
                    anchors { top: parent.top }
                    width: parent.width - wreath.width
                    text: gameData.title
                    color: "white"
                    font.pixelSize: vpx(50)
                    font.family: titleFont.name
                    font.bold: true
                    elide: Text.ElideRight
                }

                RowLayout {
                    id: metadata
                    anchors {
                        top: gameTitle.bottom
                        topMargin: vpx(0)
                    }
                    height: vpx(1)
                    spacing: vpx(6)

                    // Developer
                    GameGridMetaBox {
                        metatext: (gameData.developerList[0] != undefined) ? gameData.developerList[0] : "Unknown"
                    }

                    // Release year
                    GameGridMetaBox {
                        metatext: (gameData.release != "" ) ? gameData.release.getFullYear() : ""
                    }

                    // Players
                    GameGridMetaBox {
                        metatext: if (gameData.players > 1) {
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
                        id: spacer2
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

                Image {
                    id: wreath
                    source: (gameData.rating > 0.89) ? "../assets/images/wreath-gold.svg" : "../assets/images/wreath.svg"
                    anchors { top: parent.top; right: parent.right; rightMargin: vpx(0) }
                    asynchronous: false
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    width: vpx(75)
                    height: vpx(75)
                    opacity: (gameData.rating != "" && !showVideo) ? 1 : 0.1
                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }

                    Text {
                        id: metarating
                        anchors {
                            top: parent.top
                            topMargin: vpx(15)
                        }
                        width: parent.width
                        text: (gameData.rating == "") ? "NA" : Math.round(gameData.rating * 100)
                        color: (gameData.rating > 0.89) ? "#FFCE00" : "white"
                        font.pixelSize: vpx(35)
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

                // description
                PegasusUtils.AutoScroll {
                    id: gameDescription
                    width: parent.width
                    height: boxart.height - y
                    anchors {
                        top: metadata.bottom;
                        topMargin: vpx(35);
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignJustify
                        text: (gameData.summary || gameData.description) ? gameData.summary || gameData.description : "No description available"
                        font.pixelSize: vpx(22)
                        font.family: "Open Sans"
                        color: "#fff"
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        opacity: showVideo ? 0.1 : 1.0
                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }
                    }
                }
            }
        }

        // NOTE: Navigation
        Item {
            id: navigation
            anchors.fill: parent
            width: parent.width
            height: parent.height

            Rectangle {
                id: navigationbox
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                width: parent.width
                height: vpx(60)
                color: "#16ffffff"

                // Buttons
                Row {
                    id: panelbuttons
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height

                    // Launch button
                    GamePanelButton {
                        id: launchBtn
                        text: "Launch"
                        width: parent.width/numbuttons
                        height: parent.height

                        onFocusChanged: {
                            if (focus) {
                                navSound.play();
                            }
                        }

                        onClicked: {
                            focus = true;
                            root.launchRequested();
                        }

                        KeyNavigation.left: backBtn
                        KeyNavigation.right: (numbuttons == 4) ? videoBtn : faveBtn
                        Keys.onPressed: {
                            if(api.keys.isAccept(event) && !event.isAutoRepeat) {
                                event.accepted = true;
                                root.launchRequested();
                            }
                        }
                    }

                    Rectangle {
                        width: vpx(1)
                        height: parent.height
                        color: "#1a1a1a"
                    }

                    // Video button
                    GamePanelButton {
                        id: videoBtn
                        text: (showVideo) ? "Details" : "Preview"
                        width: parent.width / numbuttons
                        height: parent.height
                        visible: (numbuttons == 4)

                        onFocusChanged: {
                            if (focus) {
                                navSound.play();
                            }
                        }

                        onClicked: {
                            focus = true;
                            toggleVideo();
                        }

                        KeyNavigation.left: launchBtn
                        KeyNavigation.right: faveBtn
                        Keys.onPressed: {
                            if(api.keys.isAccept(event) && !event.isAutoRepeat) {
                                event.accepted = true;
                                toggleVideo();
                            }
                        }
                    }

                    Rectangle {
                        width: vpx(1)
                        height: parent.height
                        color: "#1a1a1a"
                        visible: (numbuttons == 4)
                    }

                    // Favourite button
                    GamePanelButton {
                        id: faveBtn
                        property bool isFavorite: (gameData && gameData.favorite) || false
                        text: isFavorite ? "Unfavorite" : "Add to Favorites"
                        width: parent.width/numbuttons
                        height: parent.height

                        onFocusChanged: {
                            if (focus) {
                                navSound.play();
                            }
                        }

                        onClicked: {
                            focus = true;
<<<<<<< HEAD
                            toggleFav(gameData);
                        }

                        KeyNavigation.left: (numbuttons == 5) ? videoBtn : launchBtn
                        KeyNavigation.right: playingBtn
                        Keys.onPressed: {
                            if(api.keys.isAccept(event) && !event.isAutoRepeat) {
                                event.accepted = true;
                                toggleFav(gameData);
                            }
                        }
                    }

                    Rectangle {
                        width: vpx(1)
                        height: parent.height
                        color: "#1a1a1a"
                    }

                    // Playing Collection button
                    GamePanelButton {
                        id: playingBtn
                        property bool isInPlayingCollection: (playingCollFiles != null ? playingCollFiles.includes(gameData.files.getFirst().path) : false)
                        text: isInPlayingCollection ? "Remove from Playing" : "Add to Playing"
                        width: parent.width/numbuttons
                        height: parent.height

                        onFocusChanged: {
                            if (focus) {
                                navSound.play();
                            }
                        }

                        onClicked: {
                            focus = true;
                            togglePlaying(gameData);
=======
                            toggleFav();
                        }

                        function toggleFav() {
                            if (gameData) {
                                gameData.favorite = !gameData.favorite;
                            }
                            toggleSound.play();
>>>>>>> parent of 3b226fa... Add support for "Playing" dynamic collection that can be updated from within the frontend. Also add count of games to the platform menu.
                        }

                        KeyNavigation.left: (numbuttons == 4) ? videoBtn : launchBtn
                        KeyNavigation.right: backBtn
                        Keys.onPressed: {
                            if(api.keys.isAccept(event) && !event.isAutoRepeat) {
                                event.accepted = true;
<<<<<<< HEAD
                                togglePlaying(gameData);
=======
                                toggleFav();
>>>>>>> parent of 3b226fa... Add support for "Playing" dynamic collection that can be updated from within the frontend. Also add count of games to the platform menu.
                            }
                        }
                    }

                    Rectangle {
                        width: vpx(1)
                        height: parent.height
                        color: "#1a1a1a"
                    }

                    // Back button
                    GamePanelButton {
                        id: backBtn
                        width: parent.width/numbuttons
                        height: parent.height
                        text: "Close"

                        onFocusChanged: {
                            if (focus) {
                                navSound.play();
                            }
                        }

                        onClicked: {
                            focus = true;
                            closedetails();
                        }

                        KeyNavigation.left: faveBtn
                        KeyNavigation.right: launchBtn
                        Keys.onPressed: {
                            if(api.keys.isAccept(event) && !event.isAutoRepeat) {
                                event.accepted = true;
                                closedetails();
                            }
                        }
                    }
                }
            }

            // Round those corners!
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: navigation.width
                    height: navigation.height

                    Rectangle {
                        anchors.centerIn: parent
                        width: navigation.width
                        height: navigation.height
                        radius: cornerradius
                    }
                }
            }
        }

        // Empty area for swiping on touch
        Item {
            anchors.fill: parent
            PegasusUtils.HorizontalSwipeArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: vpx(60)
                }
                onClicked: toggleVideo()
            }
        }
    }

    function intro() {
        backgroundbox.opacity = 1;
        backgroundbox.scale = 1;
        menuIntroSound.play()
    }

    function outro() {
        backgroundbox.opacity = 0;
        backgroundbox.scale = 1.03;
        menuIntroSound.play()
    }

}