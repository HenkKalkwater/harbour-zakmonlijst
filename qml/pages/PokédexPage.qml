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
                menu: ContextMenu {
                    Repeater {
                        model: pokédexesList
                        MenuItem {
                            text: model.name
                        }
                    }
                }
                description: pokédexesList.get(currentIndex).description
                onCurrentIndexChanged: window.currentPokédex = pokédexesList.get(currentIndex).id
                Component.onCompleted: {
                    for (var i = 0; i < pokédexesList.count; i++) {
                        if (pokédexesList.get(i).id === currentPokédex) {
                            currentIndex = i
                        }
                    }
                }
            }

        }
    }
}
