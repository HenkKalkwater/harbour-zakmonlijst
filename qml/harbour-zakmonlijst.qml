import QtQuick 2.6
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import "pages"
import "."

ApplicationWindow {
    id: window;
    property int currentPokédex
    property string coverMode: "default"

    // CoverMode: pokémon:
    property var coverPokémon

    initialPage: Component { PokémonListPage { } }
    cover: {
        switch(coverMode) {
        case "pokémon":
            return Qt.resolvedUrl("cover/PokémonCoverPage.qml")
        case "default":
            return Qt.resolvedUrl("cover/CoverPage.qml")
        default: //fallthrough
            console.warn("invalid coverMode")
        }
    }
    allowedOrientations: Orientation.All
    Component.onCompleted: PokéApi.initialise()
}
