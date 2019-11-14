import QtQuick 2.6
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0

ListItem {
    signal pokémonClicked(int id)
    property variant _pokéModel: model
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        Label {
            id: pokémonNo
            anchors.verticalCenter: parent.verticalCenter
            Layout.alignment: Qt.AlignLeft
            Layout.minimumWidth: Theme.fontSizeMedium * 1.5
            horizontalAlignment: Text.AlignRight
            text: model.index + 1
            //width: Theme.fontSizeMedium * 1.5
            clip: true
        }

        Image {
            id: sprite
            Layout.alignment: Qt.AlignLeft
            Layout.maximumWidth: width
            height: parent.height
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
            Layout.fillWidth: true
            anchors.verticalCenter: parent.verticalCenter
            text: model.name
        }

        Repeater {
            model: _pokéModel.types
            TypeBadge {
                typeAbbr: model.identifier
                typeName: model.name
                anchors.verticalCenter: parent.verticalCenter
            }
        }

    }
    onClicked: pokémonClicked(model.id)
}
