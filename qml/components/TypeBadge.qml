import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    property string typeAbbr: ""
    property alias typeName: badgeText.text
    width: badgeText.width + 2 * Theme.paddingMedium
    height: badgeText.height + 2 * Theme.paddingMedium
    radius: height / 2
    border.color: "black"
    border.width: 2
    color: {
        switch(typeAbbr) {
        case "bug":
            return "#88960e"
        case "dark":
            return "#4b382b"
        case "dragon":
            return "#715ad8"
        case "electric":
            return "#e79302"
        case "fairy":
            return "#e08ee0"
        case "fighting":
            return "#5f2311"
        case "fire":
            return "#c72100"
        case "flying":
            return "#5d73d4"
        case "ghost":
            return "#454593"
        case "grass":
            return "#389a02"
        case "ground":
            return "#d2b156"
        case "ice":
            return "#6dd3f5"
        case "normal":
            return "#bdb7ab"
        case "poison":
            return "#702772"
        case "psychic":
            return "#dd3267"
        case "rock":
            return "#9e863d"
        case "steel":
            return "#8e8e9f"
        case "water":
            return "#0c67c2"
        default:
            return "#000000"
        }
    }
    Text {
        id: badgeText
        color: "white"
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeTiny
        font.capitalization: Font.AllUppercase
        font.weight: Font.Bold
        style: Text.Outline
        styleColor: "black"
    }
}
