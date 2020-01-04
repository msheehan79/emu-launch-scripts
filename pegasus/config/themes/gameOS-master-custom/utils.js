// This file contains some helper scripts for formatting data

// Create a 2-level structure grouping collections by category (Summary field)
function createCollectionHierarchy(lastPlayedCollection, favoritesCollection) {
    //form a collection which contains our last played, favorites, and all real collections.
    var dynamicCollections = [lastPlayedCollection, favoritesCollection, ...api.collections.toVarArray()];

    // Create a pseudo collection to display a Back entry in the navigation for each collection category
    var back = {
        name: "< Back",
        shortName: "goback",
        summary: "< Back",
        games: null
    }

    var categories = [];
    for(let col of dynamicCollections) {
        if(categories[col.summary] === undefined) {
            // If present, the "System" category should always be the first after Last Played & Favorites so it will always get inserted there
            switch(col.summary) {
                case "System":
                    categories.splice(2, 0, col.summary);
                    break;
                default:
                    categories.push(col.summary);
                    break;
            }

            categories[col.summary] = [];
            categories[col.summary].push(back);
            categories[col.summary].push(col);
        } else {
            categories[col.summary].push(col);
        }
    }
    return categories;
}

// Returns the System tag name for a game, if present
function getSystemTagName(gameData) {
    const matches = gameData.tagList.filter(s => s.includes('System:'));
    return matches.length == 0 ? "" : matches[0].replace("System:", "");
}

// Returns the Custom Sort tag for a game/collection pair, if present
function getCustomSortTag(gameData, collName) {
    const matches = gameData.tagList.filter(s => s.includes('CustomSort:' + collName + ':'));
    return matches.length == 0 ? "" : matches[0].replace("CustomSort:" + collName + ':', "");
}

// For making any needed name adjustments to collections
function formatCollectionName(currentCollection) {
    var name = currentCollection.name;
    if (name == "Super Nintendo Entertainment System") {
        name = "Super NES"
    } else if (name == "Nintendo Entertainment System") {
        name = "NES"
    }
    return name;
}

// For multiplayer games, show the player count as '1-N'
function formatPlayers(playerCount) {
    if (playerCount === 1)
        return playerCount

    return "1-" + playerCount;
}

// Show dates in Y-M-D format
function formatDate(date) {
    return Qt.formatDate(date, "yyyy-MM-dd");
}

// Show last played time as text. Based on the code of the default Pegasus theme.
// Note to self: I should probably move this into the API.
function formatLastPlayed(lastPlayed) {
    if (isNaN(lastPlayed))
        return "never";

    var now = new Date();

    var elapsedHours = (now.getTime() - lastPlayed.getTime()) / 1000 / 60 / 60;
    if (elapsedHours < 24 && now.getDate() === lastPlayed.getDate())
        return "today";

    var elapsedDays = Math.round(elapsedHours / 24);
    if (elapsedDays <= 1)
        return "yesterday";

    return elapsedDays + " days ago"
}

// Display the play time (provided in seconds) with text.
// Based on the code of the default Pegasus theme.
// Note to self: I should probably move this into the API.
function formatPlayTime(playTime) {
    var minutes = Math.ceil(playTime / 60)
    if (minutes <= 90)
        return Math.round(minutes) + " minutes";

    return parseFloat((minutes / 60).toFixed(1)) + " hours"
}
