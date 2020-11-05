import QtQuick 2.8
import QtMultimedia 5.9
import SortFilterProxyModel 0.2

import "Home"
import "Collections"
import "Menu"
import "Games"

FocusScope {
    id: root

    focus: true

    FontLoader { id: montserratMedium; source: "./assets/fonts/Montserrat-Medium.ttf" }
    FontLoader { id: montserratBold; source: "./assets/fonts/Montserrat-Bold.ttf" }
    FontLoader { id: robotoSlabLight; source: "./assets/fonts/RobotoSlab-Light.ttf" }
    FontLoader { id: robotoSlabThin; source: "./assets/fonts/RobotoSlab-Thin.ttf" }
    FontLoader { id: robotoSlabRegular; source: "./assets/fonts/RobotoSlab-Regular.ttf" }

    // [0] = HOME
    // [1] = COLLECTIONS
    // [2] = GAMES
    property int currentMenuIndex: api.memory.get("currentMenuIndex") || 0

    property var collectionType: api.memory.get("currentCollectionType") || "System"
    property var collectionTypes: getAllCollectionTypes()

    property var allCollections: {
        var collections = api.collections.toVarArray().filter(systemCollection)

        // collections.unshift({"name": "favorites", "shortName": "favorites", "games": allFavorites})

        // // FOR TESTING PURPOSES
        // collections.unshift({"name": "all games", "shortName": "all", "games": api.allGames})
        // collections.unshift({"name": "3do", "shortName": "3do", "games": collections[6].games})
        // collections.unshift({"name": "amstradcpc", "shortName": "amstradcpc", "games": collections[6].games})
        // collections.unshift({"name": "apple2", "shortName": "apple2", "games": collections[6].games})
        // collections.unshift({"name": "atari2600", "shortName": "atari2600", "games": collections[6].games})
        // collections.unshift({"name": "atari5200", "shortName": "atari5200", "games": collections[6].games})
        // collections.unshift({"name": "atarist", "shortName": "atarist", "games": collections[6].games})
        // collections.unshift({"name": "atari7800", "shortName": "atari7800", "games": collections[6].games})
        // collections.unshift({"name": "atarilynx", "shortName": "atarilynx", "games": collections[6].games})
        // collections.unshift({"name": "atarijaguar", "shortName": "atarijaguar", "games": collections[6].games})
        // collections.unshift({"name": "cps1", "shortName": "cps1", "games": collections[6].games})
        // collections.unshift({"name": "cps2", "shortName": "cps2", "games": collections[6].games})
        // collections.unshift({"name": "cps3", "shortName": "cps3", "games": collections[6].games})
        // collections.unshift({"name": "colecovision", "shortName": "colecovision", "games": collections[6].games})
        // collections.unshift({"name": "c64", "shortName": "c64", "games": collections[6].games})
        // collections.unshift({"name": "amiga", "shortName": "amiga", "games": collections[6].games})
        // collections.unshift({"name": "intellivision", "shortName": "intellivision", "games": collections[6].games})
        // collections.unshift({"name": "msx", "shortName": "msx", "games": collections[6].games})
        // collections.unshift({"name": "msx2", "shortName": "msx2", "games": collections[6].games})
        // collections.unshift({"name": "turbografx16", "shortName": "turbografx16", "games": collections[6].games})
        // collections.unshift({"name": "pcfx", "shortName": "pcfx", "games": collections[6].games})
        // collections.unshift({"name": "fds", "shortName": "fds", "games": collections[6].games})
        // collections.unshift({"name": "wiiu", "shortName": "wiiu", "games": collections[6].games})
        // collections.unshift({"name": "atomiswave", "shortName": "atomiswave", "games": collections[6].games})
        // collections.unshift({"name": "sega32x", "shortName": "sega32x", "games": collections[6].games})
        // collections.unshift({"name": "zxspectrum", "shortName": "zxspectrum", "games": collections[6].games})
        // collections.unshift({"name": "vectrex", "shortName": "vectrex", "games": collections[6].games})
        // collections.unshift({"name": "neogeocd", "shortName": "neogeocd", "games": collections[6].games})
        // collections.unshift({"name": "ps2", "shortName": "ps2", "games": collections[6].games})
        // collections.unshift({"name": "gog", "shortName": "gog", "games": collections[6].games})
        // collections.unshift({"name": "steam", "shortName": "steam", "games": collections[6].games})
        // collections.unshift({"name": "daphne", "shortName": "daphne", "games": collections[6].games})
        // collections.unshift({"name": "fba", "shortName": "fba", "games": collections[6].games})
        // collections.unshift({"name": "fbneo", "shortName": "fbneo", "games": collections[6].games})
        // collections.unshift({"name": "mame", "shortName": "mame", "games": collections[6].games})
        // collections.unshift({"name": "3ds", "shortName": "3ds", "games": collections[6].games})
        // // END TESTING

        return collections
    }

    property int currentCollectionIndex: api.memory.get("currentCollectionIndex-" + collectionType) || 0
    property var currentCollection: allCollections[currentCollectionIndex]

    property variant dataMenu: [
        { name: "home" },
        { name: "collections" },
        { name: "games" }
    ]

    property variant dataManufacturers: {
        "sega":      { color: "#17569b" },
        "sony":      { color: "#1D1D1D" },
        "snk":       { color: "#359CD2" },
        "nec":       { color: "#2E1D81" },
        "nintendo":  { color: "#E11919" },
        "atari":     { color: "#ffffff" },
        "panasonic": { color: "#ffffff" },
        "mattel":    { color: "#ffffff" },
        "microsoft": { color: "#ffffff" },
        "coleco":    { color: "#ffffff" },
        "various":   { color: "#18A46E" },
        "valve":     { color: "#010314" },
        "sammy":     { color: "#ffffff" },
        "sharp":     { color: "#ffffff" },
        "commodore": { color: "#ffffff" }
    }

    function clearShortname(shortname) {
        return dataLaunchbox[shortname] ? dataLaunchbox[shortname] : shortname
    }

    property variant dataLaunchbox: {
        "amstrad cpc" :                             "amstradcpc",
        "apple ii" :                                "apple2",
        "atari 2600" :                              "atari2600",
        "atari 5200" :                              "atari5200",
        "atari st" :                                "atarist",
        "atari 7800" :                              "atari7800",
        "atari lynx" :                              "atarilynx",
        "atari jaguar" :                            "atarijaguar",
        "capcom cps1" :                             "cps1",
        "capcom cps2" :                             "cps2",
        "capcom cps3" :                             "cps3",
        "commodore 64" :                            "c64",
        "commodore amiga" :                         "amiga",
        "mattel intellivision" :                    "intellivision",
        "microsoft msx" :                           "msx",
        "microsoft msx2" :                          "msx2",
        "nec turbografx-16" :                       "turbografx16",
        "pc engine supergrafx" :                    "supergrafx",
        "nec pc-fx" :                               "pcfx",
        "nintendo entertainment system" :           "nes",
        "nintendo famicom disk system" :            "fds",
        "nintendo game boy" :                       "gb",
        "super nintendo entertainment system" :     "snes",
        "nintendo 64" :                             "n64",
        "nintendo game boy color" :                 "gbc",
        "nintendo game boy advance" :               "gba",
        "nintendo gamecube" :                       "gc",
        "nintendo ds" :                             "nds",
        "nintendo wii" :                            "wii",
        "nintendo 3ds" :                            "3ds",
        "nintendo wii u" :                          "wiiu",
        "3do interactive multiplayer" :             "3do",
        "sammy atomiswave" :                        "atomiswave",
        "sega master system" :                      "mastersystem",
        "sega genesis" :                            "genesis",
        "sega mega drive" :                         "megadrive",
        "sega game gear" :                          "gamegear",
        "sega cd" :                                 "segacd",
        "sega 32x" :                                "sega32x",
        "sega saturn" :                             "saturn",
        "sega dreamcast" :                          "dreamcast",
        "sinclair zx spectrum" :                    "zxspectrum",
        "gce vectrex" :                             "vectrex",
        "snk neo geo aes" :                         "neogeo",
        "snk neo geo mvs":                          "neogeo",
        "snk neo geo cd" :                          "neogeocd",
        "snk neo geo pocket" :                      "ngp",
        "snk neo geo pocket color" :                "ngpc",
        "sony playstation" :                        "psx",
        "sony playstation 2" :                      "ps2",
        "sony psp" :                                "psp",
        "final burn alpha" :                        "fba",
        "final burn neo" :                          "fbneo"
    }

    // Additional data to display manufacturers and release dates
    property variant dataConsoles: {
        "default":            { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "Default"                       },
        "amstradcpc":         { manufacturer: "amstrad",           release: "1984", color: "#000000", altColor: "#252525", fullName: "Amstrad CPC"                   },
        "apple2":             { manufacturer: "apple",             release: "1977", color: "#000000", altColor: "#252525", fullName: "Apple II"                      },
        "atari2600":          { manufacturer: "atari",             release: "1977", color: "#000000", altColor: "#252525", fullName: "Atari 2600"                    },
        "atari5200":          { manufacturer: "atari",             release: "1982", color: "#06478B", altColor: "#0B55A3", fullName: "Atari 5200"                    },
        "atarist":            { manufacturer: "atari",             release: "1985", color: "#000000", altColor: "#252525", fullName: "Atari ST"                      },
        "atari7800":          { manufacturer: "atari",             release: "1986", color: "#5E0811", altColor: "#252525", fullName: "Atari 7800"                    },
        "atarilynx":          { manufacturer: "atari",             release: "1989", color: "#000000", altColor: "#252525", fullName: "Atari Lynx"                    },
        "atarijaguar":        { manufacturer: "atari",             release: "1993", color: "#000000", altColor: "#252525", fullName: "Atari Jaguar"                  },
        "cps1":               { manufacturer: "capcom",            release: "1988", color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "cps2":               { manufacturer: "capcom",            release: "1993", color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "cps3":               { manufacturer: "capcom",            release: "1996", color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "colecovision":       { manufacturer: "coleco",            release: "1982", color: "#F59752", altColor: "#252525", fullName: "ColecoVision"                  },
        "c64":                { manufacturer: "commodore",         release: "1982", color: "#000000", altColor: "#252525", fullName: "Commodore 64"                  },
        "amiga":              { manufacturer: "commodore",         release: "1985", color: "#000000", altColor: "#252525", fullName: "Amiga"                         },
        "intellivision":      { manufacturer: "mattel",            release: "1979", color: "#000000", altColor: "#252525", fullName: "Intellivision"                 },
        "msx":                { manufacturer: "microsoft",         release: "1983", color: "#000000", altColor: "#252525", fullName: "MSX"                           },
        "msx2":               { manufacturer: "microsoft",         release: "1985", color: "#000000", altColor: "#252525", fullName: "MSX2"                          },
        "pcengine":           { manufacturer: "nec",               release: "1987", color: "#96040C", altColor: "#7E040B", fullName: "PC Engine"                     },
        "turbografx16":       { manufacturer: "nec",               release: "1987", color: "#E17400", altColor: "#A45500", fullName: "TurboGrafx 16"                 },
        "turbografxcd":       { manufacturer: "nec",               release: "1989", color: "#E17400", altColor: "#A45500", fullName: "TurboGrafx CD"                 },
        "supergrafx":         { manufacturer: "nec",               release: "1989", color: "#000000", altColor: "#252525", fullName: "SuperGrafx"                    },
        "sgfx":               { manufacturer: "nec",               release: "1989", color: "#000000", altColor: "#252525", fullName: "SuperGrafx"                    },
        "pcfx":               { manufacturer: "nec",               release: "1994", color: "#000000", altColor: "#252525", fullName: "PC-FX"                         },
        "nes":                { manufacturer: "nintendo",          release: "1983", color: "#272727", altColor: "#656565", fullName: "Nintendo Entertainment System" },
        "fds":                { manufacturer: "nintendo",          release: "1986", color: "#000000", altColor: "#252525", fullName: "Famicom Disk System"           },
        "gb":                 { manufacturer: "nintendo",          release: "1989", color: "#031268", altColor: "#010D50", fullName: "Game Boy"                      },
        "snes":               { manufacturer: "nintendo",          release: "1990", color: "#84E8A7", altColor: "#65A57B", fullName: "Super Nintendo"                },
        "n64":                { manufacturer: "nintendo",          release: "1996", color: "#45832D", altColor: "#356F20", fullName: "Nintendo 64"                   },
        "gbc":                { manufacturer: "nintendo",          release: "1998", color: "#997F03", altColor: "#725E00", fullName: "Game Boy Color"                },
        "gba":                { manufacturer: "nintendo",          release: "2001", color: "#1E02B4", altColor: "#19077C", fullName: "Game Boy Advance"              },
        "gc":                 { manufacturer: "nintendo",          release: "2001", color: "#441BA3", altColor: "#24066A", fullName: "Nintendo GameCube"             },
        "gamecube":           { manufacturer: "nintendo",          release: "2001", color: "#441BA3", altColor: "#24066A", fullName: "Nintendo GameCube"             },
        "nds":                { manufacturer: "nintendo",          release: "2004", color: "#B4B4B4", altColor: "#363636", fullName: "Nintendo DS"                   },
        "wii":                { manufacturer: "nintendo",          release: "2006", color: "#75C4D4", altColor: "#D2EBF0", fullName: "Nintendo Wii"                  },
        "wiiware":            { manufacturer: "nintendo",          release: "2006", color: "#75C4D4", altColor: "#D2EBF0", fullName: "Nintendo WiiWare"              },
        "3ds":                { manufacturer: "nintendo",          release: "2011", color: "#000000", altColor: "#252525", fullName: "Nintendo 3DS"                  },
        "wiiu":               { manufacturer: "nintendo",          release: "2012", color: "#000000", altColor: "#252525", fullName: "Nintendo Wii U"                },
        "virtualboy":         { manufacturer: "nintendo",          release: "1995", color: "#AA0000", altColor: "#830000", fullName: "Virtual Boy"                   },
        "3do":                { manufacturer: "panasonic",         release: "1993", color: "#000000", altColor: "#252525", fullName: "3DO"                           },
        "atomiswave":         { manufacturer: "sammy",             release: "2003", color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "mastersystem":       { manufacturer: "sega",              release: "1985", color: "#A71010", altColor: "#790303", fullName: "Sega Master System"            },
        "genesis":            { manufacturer: "sega",              release: "1988", color: "#230000", altColor: "#180000", fullName: "Sega Genesis"                  },
        "megadrive":          { manufacturer: "sega",              release: "1988", color: "#230000", altColor: "#180000", fullName: "Sega Megadrive"                },
        "gamegear":           { manufacturer: "sega",              release: "1990", color: "#0D1114", altColor: "#1F1F1F", fullName: "Game Gear"                     },
        "segacd":             { manufacturer: "sega",              release: "1991", color: "#010314", altColor: "#02062B", fullName: "Sega CD"                       },
        "sega32x":            { manufacturer: "sega",              release: "1994", color: "#000000", altColor: "#252525", fullName: "Sega 32X"                      },
        "saturn":             { manufacturer: "sega",              release: "1994", color: "#3B3A9C", altColor: "#292885", fullName: "Sega Saturn"                   },
        "dreamcast":          { manufacturer: "sega",              release: "1998", color: "#FB7A33", altColor: "#C0571C", fullName: "Sega Dreamcast"                },
        "sg1000":             { manufacturer: "sega",              release: "1983", color: "#000000", altColor: "#252525", fullName: "Sega SG-1000"                  },
        "zxspectrum":         { manufacturer: "sinclair",          release: "1982", color: "#000000", altColor: "#252525", fullName: "ZX Spectrum"                   },
        "vectrex":            { manufacturer: "smith_engineering", release: "1982", color: "#000000", altColor: "#252525", fullName: "Vectrex"                       },
        "x68000":             { manufacturer: "sharp",             release: "1987", color: "#AA0000", altColor: "#830000", fullName: "X68000"                        },
        "neogeo":             { manufacturer: "snk",               release: "1990", color: "#08B5D5", altColor: "#008199", fullName: "Neo Geo"                       },
        "neogeocd":           { manufacturer: "snk",               release: "1994", color: "#000000", altColor: "#252525", fullName: "Neo Geo CD"                    },
        "ngp":                { manufacturer: "snk",               release: "1998", color: "#93192D", altColor: "#6B0909", fullName: "Neo Geo Pocket"                },
        "ngpc":               { manufacturer: "snk",               release: "1999", color: "#460674", altColor: "#5C056B", fullName: "Neo Geo Pocket Color"          },
        "psx":                { manufacturer: "sony",              release: "1994", color: "#D9BE36", altColor: "#252525", fullName: "PlayStation"                   },
        "ps2":                { manufacturer: "sony",              release: "2000", color: "#3144B1", altColor: "#00224C", fullName: "PS2"                           },
        "psp":                { manufacturer: "sony",              release: "2004", color: "#050C10", altColor: "#6A818C", fullName: "PSP"                           },
        "pspminis":           { manufacturer: "sony",              release: "2004", color: "#050C10", altColor: "#6A818C", fullName: "PSP Minis"                     },
        "gog":                { manufacturer: "pc",                release: "2008", color: "#000000", altColor: "#252525", fullName: "GOG"                           },
        "steam":              { manufacturer: null,                release: "2003", color: "#010314", altColor: "#252525", fullName: "Steam"                         },
        "arcade":             { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-mame":        { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-neogeo":      { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-naomi":       { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-fbneo":       { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-atomiswave":  { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-model2":      { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-model3":      { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-stv":         { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-taito":       { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "arcade-teknoparrot": { manufacturer: null,                release: null,   color: "#D00E2D", altColor: "#9B071E", fullName: "Arcade"                        },
        "all":                { manufacturer: null,                release: null,   color: "#FFD019", altColor: "#FF9919", fullName: "Default"                       },
        "daphne":             { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "Daphne"                        },
        "fba":                { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "fbneo":              { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "mame":               { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "Arcade"                        },
        "ports":              { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "PC"                            },
        "scummvm":            { manufacturer: null,                release: null,   color: "#000000", altColor: "#252525", fullName: "PC"                            },
    }

    SortFilterProxyModel {
        id: allFavorites
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "favorite"; value: true; }
    }

    state: dataMenu[currentMenuIndex].name

    transitions: [
        Transition {
            from: "home"
            to: "collections"
            PropertyAnimation {
                target: home;
                property: "x";
                from: 0;
                to: -root.width;
                duration: 150
            }
            PropertyAnimation {
                target: collections;
                property: "x";
                from: root.width;
                to: 0;
                duration: 150
            }
        },
        Transition {
            from: "collections"
            to: "home"
            PropertyAnimation {
                target: home;
                property: "x";
                from: -root.width;
                to: 0;
                duration: 150
            }
            PropertyAnimation {
                target: collections;
                property: "x";
                from: 0;
                to: root.width;
                duration: 150
            }
        },
        Transition {
            from: "collections"
            to: "games"
            PropertyAnimation {
                target: collections;
                property: "x";
                from: 0;
                to: -root.width;
                duration: 150
            }
            PropertyAnimation {
                target: games;
                property: "x";
                from: root.width;
                to: 0;
                duration: 150
            }
        },
        Transition {
            from: "games"
            to: "collections"
            PropertyAnimation {
                target: collections;
                property: "x";
                from: -root.width;
                to: 0;
                duration: 150
            }
            PropertyAnimation {
                target: games;
                property: "x";
                from: 0;
                to: root.width;
                duration: 150
            }
        }
    ]

    Rectangle {
        id: rect_main
        width: parent.width
        height: parent.height
        color: "white"
    }

    Home {
        id: home
        width: root.width
        height: root.height * 0.9
        anchors.bottom: root.bottom
        focus: ( root.state === "home" )
        opacity: focus
        visible: opacity
    }

    Collections {
        id: collections
        width: root.width
        height: root.height
        focus: ( root.state === "collections" )
        opacity: focus
        visible: opacity
    }

    Games {
        id: games
        width: root.width
        height: root.height * 0.9
        anchors.bottom: root.bottom
        focus: ( root.state === "games" )
        opacity: focus
        visible: opacity
    }

    Menu {
        id: menu
        width: root.width
        height: root.height * 0.1
        anchors {
            top: root.top
        }
        focus: true
    }

    Keys.onPressed: {
        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            if (currentMenuIndex > 0)
                currentMenuIndex--
        }

        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            if (currentMenuIndex < (dataMenu.length - 1))
                currentMenuIndex++
        }

        if (api.keys.isFilters(event)) {
            var index = collectionTypes.indexOf(collectionType) + 1;
            collectionType = (index < collectionTypes.length) ? collectionTypes[index] : collectionTypes[0];
            currentCollectionIndex = api.memory.get("currentCollectionIndex-" + collectionType) || 0;
        }
    }

    function saveCurrentState(currentGameIndex, sortIndex) {
        api.memory.set("currentMenuIndex", currentMenuIndex);
        api.memory.set("currentCollectionType", collectionType);
        api.memory.set("currentCollectionIndex-" + collectionType, currentCollectionIndex);
        if (sortIndex !== undefined) {
            api.memory.set('sortIndex', sortIndex);
        }
        if (currentGameIndex !== undefined) {
            api.memory.set(collectionType + "-" + currentCollectionIndex + "-currentGameIndex", currentGameIndex);
        }
    }

    function systemCollection(coll) {
        return coll.summary == collectionType
    }

    function getAllCollectionTypes() {
        var types = [];
        var collections = api.collections.toVarArray().forEach(function(value, index, array) {
                types.push(value.summary);
            }
        );
        return Array.from(new Set(types));
    }

    // SoundEffect {
    //     id: sfxFlip
    //     source: "assets/sounds/flip_card.wav"
    //     volume: 0.5
    // }

}