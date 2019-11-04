// Secretary theme for Pegasus
// Copyright (C) 2019  Mátyás Mustoha


import QtQuick 2.6
import SortFilterProxyModel 0.2


FocusScope {
    readonly property int baseFontSize: height / 720.0 * 13

    readonly property var allowedDevs: inDev.model.filter(e => e.selected).map(e => e.name)
    readonly property var allowedPubs: inPub.model.filter(e => e.selected).map(e => e.name)
    readonly property var allowedGenres: inGenre.model.filter(e => e.selected).map(e => e.name)
    readonly property var allowedTags: inTag.model.filter(e => e.selected).map(e => e.name)
    readonly property var allowedCollGames: {
        const allowedCollNames = inColl.model.filter(e => e.selected).map(e => e.name);
        const allowedColls = api.collections.toVarArray().filter(e => allowedCollNames.includes(e.name));
        return [].concat( ...allowedColls.map(coll => coll.games.toVarArray()) );
    }

    function uniqueGameValues(fieldName) {
        const set = new Set();
        api.allGames.toVarArray().forEach(game => {
            game[fieldName].forEach(v => set.add(v));
        });
        return [...set.values()].sort();
    }

    Rectangle {
        id: panel
        color: "#ccc"
        anchors.left: parent.left
        anchors.right: parent.right
        height: open ? openHeight : closedHeight

        property bool open: true
        readonly property int closedHeight: panelGrid.children[0].height + panelGrid.rowSpacing
        readonly property int openHeight: panelGrid.height
        clip: true

        // NOTE: There are a few other animations overlapping with this one,
        // which is why there's some manual management here
        Behavior on height {
            NumberAnimation {
                id: panelToggleAnim
                property bool enabled: !panel.open
                duration: enabled ? 120 : 0
                onRunningChanged: if (!running) enabled = false
            }
        }

        Row {
            anchors.fill: parent

            PanelToggler {
                id: toggle
                isLeftSide: true
                isOpen: panel.open
                onClicked: {
                    panelToggleAnim.enabled = true;
                    panel.open = !panel.open;
                }
                padding: panelGrid.topPadding + baseFontSize * 0.4
            }

            Grid {
                id: panelGrid
                width: parent.width - toggle.width
                columns: 2

                readonly property double firstColumnW: 0.20 * width
                readonly property double secondColumnW: width - firstColumnW - topPadding
                rowSpacing: baseFontSize
                topPadding: rowSpacing / 2
                bottomPadding: topPadding

                PanelLabel { text: "Name contains:"; height: font.pixelSize * 2.5 }
                PanelInputBase {
                    id: inName
                    placeholderText: "(any)"
                    width: parent.secondColumnW
                }

                PanelLabel { text: "Developers:" }
                PanelMultiPick {
                    id: inDev
                    initialModel: uniqueGameValues('developerList')
                }

                PanelLabel { text: "Publishers:" }
                PanelMultiPick {
                    id: inPub
                    initialModel: uniqueGameValues('publisherList')
                }

                PanelLabel { text: "Genres:" }
                PanelMultiPick {
                    id: inGenre
                    initialModel: uniqueGameValues('genreList')
                }

                PanelLabel { text: "Tags:" }
                PanelMultiPick {
                    id: inTag
                    initialModel: uniqueGameValues('tagList')
                }

                PanelLabel { text: "Collections:" }
                PanelMultiPick {
                    id: inColl
                    initialModel: api.collections.toVarArray().map(coll => coll.name)
                }

                PanelLabel { text: "Release year:"; height: font.pixelSize * 2.5 }
                PanelMinMax { id: inYear; acceptedMin: 1900; acceptedMax: 2100 }

                PanelLabel { text: "Players:"; height: font.pixelSize * 2.5 }
                PanelMinMax { id: inPlayers; acceptedMin: 1; acceptedMax: 100 }
            }
        }
    }


    SortFilterProxyModel {
        id: filteredModel
        sourceModel: api.allGames
        filters: [
            RegExpFilter {
                roleName: "title"
                pattern: inName.text
                caseSensitivity: Qt.CaseInsensitive
            },
            ExpressionFilter {
                enabled: allowedDevs.length
                expression: allowedDevs && developerList.some(v => allowedDevs.includes(v))
            },
            ExpressionFilter {
                enabled: allowedPubs.length
                expression: allowedPubs && publisherList.some(v => allowedPubs.includes(v))
            },
            ExpressionFilter {
                enabled: allowedGenres.length
                expression: allowedGenres && genreList.some(v => allowedGenres.includes(v))
            },
            ExpressionFilter {
                enabled: allowedTags.length
                expression: allowedTags && tagList.some(v => allowedTags.includes(v))
            },
            ExpressionFilter {
                enabled: allowedCollGames.length
                expression: allowedCollGames.includes(api.allGames.get(index))
            },
            ExpressionFilter {
                expression: releaseYear == 0 || (inYear.min <= releaseYear && releaseYear <= inYear.max)
            },
            RangeFilter {
                roleName: "players"
                minimumValue: inPlayers.min
                maximumValue: inPlayers.max
            }
        ]
        sorters: [
            RoleSorter {
                id: sorter
                roleName: "sortTitle"

                readonly property bool isAscending: sortOrder == Qt.AscendingOrder

                function changeTo(fieldName) {
                    sorter.enabled = true;

                    if (fieldName === roleName) {
                        sortOrder = isAscending
                            ? Qt.DescendingOrder
                            : Qt.AscendingOrder;
                    }
                    else {
                        roleName = fieldName;
                        sortOrder = Qt.AscendingOrder;
                    }
                }
            }
        ]
    }


    Rectangle {
        id: tableHead
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: panel.bottom
        height: baseFontSize * 3
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ddd" }
            GradientStop { position: 1.0; color: "#aaa" }
        }

        Row {
            anchors.fill: parent

            ListHeaderCell {
                baseText: "#"
                width: parent.width * 0.05
            }
            ListHeaderCell {
                baseText: "Title"
                width: parent.width * 0.35
                isActive: sorter.roleName === "sortTitle"
                isAscending: sorter.isAscending
                onClicked: sorter.changeTo("sortTitle")
            }
            ListHeaderCell {
                baseText: "Developer/Publisher"
                width: parent.width * 0.35
                isActive: sorter.roleName === "developer"
                isAscending: sorter.isAscending
                onClicked: sorter.changeTo("developer")
            }
            ListHeaderCell {
                baseText: "Release"
                width: parent.width * 0.1
                isActive: sorter.roleName === "release"
                isAscending: sorter.isAscending
                onClicked: sorter.changeTo("release")
            }
            ListHeaderCell {
                baseText: "Players"
                width: parent.width * 0.1
                isActive: sorter.roleName === "players"
                isAscending: sorter.isAscending
                onClicked: sorter.changeTo("players")
            }
            ListHeaderCell {
                baseText: "Fav."
                width: parent.width * 0.05
                isActive: sorter.roleName === "favorite"
                isAscending: sorter.isAscending
                onClicked: sorter.changeTo("favorite")
            }
        }
    }


    ListView {
        id: gameList

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: tableHead.bottom
        anchors.bottom: parent.bottom
        visible: height > 0
        clip: true

        boundsBehavior: Flickable.OvershootBounds

        model: filteredModel
        delegate: Item {
            width: gameList.width
            height: baseFontSize * 2.5

            Row {
                anchors.fill: parent

                ListRowCell {
                    text: index + 1
                    width: parent.width * 0.05
                }
                ListRowCell {
                    text: modelData.title
                    width: parent.width * 0.35
                }
                ListRowCell {
                    text: [...new Set([modelData.developer, modelData.publisher].filter(v => v))].join(" / ")
                    width: parent.width * 0.35
                }
                ListRowCell {
                    text: !isNaN(modelData.release) ? modelData.release.toISOString().substring(0, 10) : ""
                    width: parent.width * 0.1
                }
                ListRowCell {
                    text: "\uC6C3".repeat(modelData.players)
                    width: parent.width * 0.1
                    opacity: modelData.players > 1 ? 1.0 : 0.4
                }
                ListRowCell {
                    text: modelData.favorite ? "\u2764" : ""
                    width: parent.width * 0.05
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#ddd"
                visible: listItemMouse.containsMouse
                z: -1
            }

            MouseArea {
                id: listItemMouse
                hoverEnabled: true
                anchors.fill: parent
                onDoubleClicked: modelData.launch()
            }
        }

        Rectangle {
            z: -1
            anchors.fill: parent
            color: "#ededed"
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: panel.bottom
        anchors.bottom: parent.bottom

        ListRowCellSep { anchors.leftMargin: parent.width * 0.05 }
        ListRowCellSep { anchors.leftMargin: parent.width * 0.40 }
        ListRowCellSep { anchors.leftMargin: parent.width * 0.75 }
        ListRowCellSep { anchors.leftMargin: parent.width * 0.85 }
        ListRowCellSep { anchors.leftMargin: parent.width * 0.95 }
    }
}
