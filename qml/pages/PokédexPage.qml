import QtQuick 2.6
import Sailfish.Silica 1.0

import ".."

Page {
    id: pokédexPage
    property ListModel pokédexModel
    property int currentPokédex
    property var changeFunction

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
                onCurrentIndexChanged: changeFunction(currentIndex)
                description: pokédexModel.get(currentIndex).description || qsTr("Still loading")
                //onCurrentIndexChanged: window.currentPokédex = PokéApi.pokédexesModel.get(currentIndex).id
            }
        }
    }
}
