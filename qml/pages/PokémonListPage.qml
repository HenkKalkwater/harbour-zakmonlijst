import QtQuick 2.0
import Sailfish.Silica 1.0;

Page {
    id: pokémonListPage
    anchors.fill: parent
    SilicaListView {
        anchors.fill: parent;
        model: pokémonList
        header: PageHeader {
            title: qsTr("Pokémon List")
        }
        delegate: ListItem {
            Image {
                id: sprite
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.topMargin: Theme.paddingMedium
                anchors.bottomMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height - anchors.topMargin * 2
                width: height
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl("../sprites/" + model.id + ".png")
                BusyIndicator {
                    anchors.centerIn: parent
                    running: sprite.status != Image.Ready
                    size: BusyIndicatorSize.ExtraSmall
                }
            }
            Label {
                anchors.left: sprite.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                text: model.name
            }

            onClicked: pageStack.push(Qt.resolvedUrl("PokémonPage.qml"), {
                                          "pokémon": pokémonList.get(model.index),
                                      })
        }
        VerticalScrollDecorator {}
    }

    onStatusChanged: {
        switch(status) {
        case PageStatus.Activating:
            window.coverMode = "default";
            break;
        case PageStatus.Active:
            pageStack.pushAttached(Qt.resolvedUrl("PokédexPage.qml"))
            break;
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: pokémonList.count == 0
        size: BusyIndicatorSize.Large
    }
}
