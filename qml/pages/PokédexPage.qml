import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: pokédexPage
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
                label: qsTr("Pokédex")
                currentIndex: 0
                menu: ContextMenu {
                    Repeater {
                        model: pokédexesList
                        MenuItem {
                            text: model.name
                        }
                    }
                }
                onCurrentIndexChanged: pokéApi.loadPokédex(pokédexesList.get(currentIndex).id)
                description: pokédexesList.get(currentIndex).description
            }
        }
    }
}
