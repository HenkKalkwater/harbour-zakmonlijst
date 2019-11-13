import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

CoverBackground {
    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        Label {
            id: pokemonName
            anchors.horizontalCenter: parent.horizontalCenter
            text: window.coverPokémon.name
        }
        Image {
            id: pokéPic
            anchors.horizontalCenter: parent.horizontalCenter
            source: Qt.resolvedUrl("../sprites/" + window.coverPokémon.id + ".png")
            height: width
            fillMode: Image.PreserveAspectFit
            width: parent.width
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: window.coverPokémon.types
                TypeBadge {
                    typeAbbr: modelData.identifier
                    typeName: modelData.name
                }
            }
        }
    }
}
