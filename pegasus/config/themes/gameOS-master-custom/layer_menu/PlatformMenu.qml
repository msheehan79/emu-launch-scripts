import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import "qrc:/qmlutils" as PegasusUtils
import "../utils.js" as Utils

Item {
    id: root

    signal menuCloseRequested
    signal switchCollection(int collectionIdx)

    property alias menuwidth: menubar.width
    property alias catList: collectionCategoryList
    property alias collList: collectionList
    property var collection
    property int categoryIdx
    property int collectionIdx
    property bool showSystemMenu: true

    Keys.onLeftPressed: closeMenu()
    Keys.onRightPressed: closeMenu()

    Keys.onPressed: {
        if(event.isAutoRepeat)
            return;

        if(api.keys.isAccept(event)) {
            event.accepted = true;
            if(collectionCategoryList.focus == true) {
                showCollectionMenu();
            } else if((collectionList.focus == true && collectionList.currentIndex == 0)) {
                showCategoryMenu();
            } else {
                switchCollection(collectionList.currentIndex);
                closeMenu();
            }
            return;
        }

        if(api.keys.isCancel(event)) {
            if(collectionList.focus == true) {
                event.accepted = true;
                showCategoryMenu();
            } else if(showSystemMenu) {
                showSystemMenu = false;
            } else {
                event.accepted = true;
                closeMenu();
            }
            return;
        }

        if(api.keys.isFilters(event)) {
            event.accepted = true;
            filtersRequested();
            return;
        }

        if(api.keys.isNextPage(event)) {
            event.accepted = true;
            api.collections.incrementIndex();
            return;
        }

        if(api.keys.isPrevPage(event)) {
            event.accepted = true;
            api.collections.decrementIndex();
            return;
        }
    }

    function closeMenu() {
        menuCloseRequested();
        showSystemMenu = true;
    }

    property var backgroundcontainer

    width: parent.width
    height: parent.height

    Item {
        id: menubg
        width: vpx(350)
        height: parent.height
        x: -width
        Behavior on x {
            PropertyAnimation {
                duration: 300;
                easing.type: Easing.OutQuart;
                easing.amplitude: 2.0;
                easing.period: 1.5
            }
        }

        PegasusUtils.HorizontalSwipeArea {
            anchors.fill: parent
            onSwipeLeft: closeMenu()
        }

        Rectangle {
            id: menubar
            property real contentWidth: width - vpx(100)
            width: parent.width
            height: parent.height
            color: "#000"
            opacity: 0
        }

        Image {
            id: logo
            width: menubar.contentWidth
            height: vpx(75)

            fillMode: Image.PreserveAspectFit
            source: "../assets/images/logos/" + collection.shortName
            asynchronous: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: vpx(80)
            opacity: 0.75
        }

        // Highlight
        Component {
            id: highlight
            Rectangle {
                color: "#FF9E12"
            }
        }

        // Menu - Category level
        ListView {
            id: collectionCategoryList
            width: parent.width
            anchors {
                top: logo.bottom
                topMargin: vpx(70)
                bottom: parent.bottom
                bottomMargin: vpx(80)
                left: parent.left
                right: parent.right
            }

            model: collectionData
            delegate: collectionListItemDelegate
            currentIndex: categoryIdx

            preferredHighlightBegin: vpx(160); 
            preferredHighlightEnd: vpx(160)
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 75
            keyNavigationWraps: true
            highlight: highlight
            highlightFollowsCurrentItem: true
            focus: true
            visible: true
        }

        // Menu - Collection level
        ListView {
            id: collectionList
            width: parent.width
            anchors {
                top: logo.bottom
                topMargin: vpx(70)
                bottom: parent.bottom
                bottomMargin: vpx(80)
                left: parent.left
                right: parent.right
            }

            model: getCollectionData()
            delegate: collectionListItemDelegate
            currentIndex: collectionIdx

            preferredHighlightBegin: vpx(160);
            preferredHighlightEnd: vpx(160)
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 75
            keyNavigationWraps: true
            highlight: highlight
            highlightFollowsCurrentItem: true
            focus: false
            visible: false
        }

        // Menu item
        Component {
            id: collectionListItemDelegate
        
            Item {
                id: menuitem
                readonly property bool selected: ListView.isCurrentItem
                width: menubar.width
                height: vpx(40)

                Text {
                    text: getCollectionName(modelData)
                    height: vpx(40)
                    anchors { 
                        left: parent.left
                        leftMargin: vpx(50)
                    }
                    color: selected ? "#fff" : "#666"
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuart
                            easing.amplitude: 2.0
                            easing.period: 1.5
                        }
                    }
                    font.pixelSize: vpx(25)
                    font.family: globalFonts.sans
                    font.bold: selected
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: menuitem
                    hoverEnabled: true
                    onEntered: {}
                    onExited: {}
                    onWheel: {}
                    onClicked: {
                        if(collectionCategoryList.focus == true) {
                            collectionCategoryList.currentIndex = index;
                            showCollectionMenu();
                        } else if((collectionList.focus == true && index == 0)) {
                            showCategoryMenu();
                        } else {
                            switchCollection(index);
                            closeMenu();
                        }                        
                    }
                }
            }
        }

        LinearGradient {
            width: vpx(2)
            height: parent.height
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00ffffff" }
                GradientStop { position: 0.5; color: "#ffffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
            opacity: 0.2
        }
    }

    MouseArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: menubg.right
            right: parent.right
        }
        onClicked: {toggleMenu()}
        visible: parent.focus
    }

    function intro() {
        menubg.x = 0;
        menuIntroSound.play();
    }

    function outro() {
        menubg.x = -menubar.width;
        menuIntroSound.play();
    }

    function showCollectionMenu() {
        collectionList.focus = true;
        collectionList.visible = true;
        collectionCategoryList.visible = false;
    }

    function showCategoryMenu() {
        collectionCategoryList.focus = true;
        collectionCategoryList.visible = true;
        collectionList.visible = false;
    }

    function getCollectionName(modelData) {
        if(typeof modelData === 'object') {
            return modelData.name;
        } else {
            return modelData;
        }        
    }

    function getCollectionData() {
        var category = collectionData[collectionCategoryList.currentIndex];
        return collectionData[category];
    }

}
