// This file contains some helper scripts for formatting data

// Returns the System tag name for a game, if present
function getSystemTagName(gameData) {
    const matches = gameData.tagList.filter(s => s.includes('System:'));
    return matches.length == 0 ? "" : matches[0].replace("System:", "");
}

// Hack to set custom sort order using the name field
function formatCollectionName(currentCollection) {
    var name = currentCollection.name;
    if (name == "Super Nintendo Entertainment System") {
        name = "Super NES"
    } else if (name == "Nintendo Entertainment System") {
        name = "NES"
    } else if (name.startsWith("Z -")) {
        name = currentCollection.name.substring(4);
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

