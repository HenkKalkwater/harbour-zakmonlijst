import QtQuick 2.6
import Sailfish.Silica 1.0

import ".."

Page {
    id: pokédexPage
    property ListModel pokédexModel
    property int currentPokédex
    property var changePokédex
    property ListModel gamesModel
    property int currentGame
    property var changeGame

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height
        Column {
            id: content
            width: parent.width
            PageHeader {
                title: qsTr("Filter")
            }

            ComboBox {
                label: qsTr("Game")
                menu: ContextMenu {
                    id: gamesContextMenu
                    Repeater {
                        model: gamesModel
                        MenuItem {
                            text: model.name
                        }
                    }
                }
                description: qsTr("The selected game will influence the Pokémon descriptions, locations etc")
                currentIndex: currentGame
                onCurrentIndexChanged: changeGame(currentIndex)
            }

            ComboBox {
                label: qsTr("Pokédex")
                menu: ContextMenu {
                    id: pokédexContextMenu
                    Repeater {
                        model: pokédexModel
                        MenuItem {
                            text: model.name
                        }
                    }
                }
                currentIndex: currentPokédex
                onCurrentIndexChanged: changePokédex(currentIndex)
                description: pokédexModel.get(currentIndex).description || qsTr("Still loading")
                //onCurrentIndexChanged: window.currentPokédex = PokéApi.pokédexesModel.get(currentIndex).id
            }
        }
    }
}
