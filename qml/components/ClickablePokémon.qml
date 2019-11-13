import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

BackgroundItem {
    property var pokémon
    id: background
    width: pokémonContainer.width
    height: pokémonContainer.height

    Item {
        id: pokémonContainer
        height: pokémonImg.height + pokémonName.height + Theme.paddingSmall
        width: Math.max(pokémonImg.width, pokémonName.width)
        anchors.centerIn: parent
        Image {
            id: pokémonImg
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            height: 256
            width: height
            source: pokémon ? "../sprites/" + pokémon.id + ".png" : "image://theme/icon-m-question"
        }
        Label {
            id: pokémonName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: pokémonImg.bottom
            anchors.topMargin: Theme.paddingSmall
            text: pokémon ? pokémon.name : qsTr("loading")
        }
    }
    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/PokémonPage.qml"),
                       { "pokémonId": pokémon.id })
    }
}
