import QtQuick 2.6
import Sailfish.Silica 1.0

//TODO: fix the botched "table" layout
Column {
    id: moveList
    property alias model: repeater.model
    property bool showLvl: true
    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        Label {
            text: qsTr("Lv.")
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            width: 0.05 * parent.width
            visible: showLvl
        }

        Label {
            text: qsTr("Name")
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            width: (showLvl ? 0.45 : 0.5) * parent.width + (showLvl ? 0 : Theme.paddingMedium)
        }

        Label {
            text: qsTr("Pwr")
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            width: 0.1 * parent.width
        }

        Label {
            text: qsTr("PP")
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            width: 0.1 * parent.width
        }

        Label {
            text: qsTr("Type")
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            width: 0.2 * parent.width
        }
    }

    ColumnView {
        id: repeater
        itemHeight: Theme.itemSizeSmall
        delegate: BackgroundItem {
            height: Theme.itemSizeSmall
            contentHeight: Theme.itemSizeSmall
            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                Label {
                    id: moveLvl
                    text: modelData.level
                    width: 0.05 * parent.width
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    visible: showLvl
                }

                Label {
                    id: moveName
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.name
                    width: (showLvl ? 0.45 : 0.5) * parent.width + (showLvl ? 0 : Theme.paddingMedium)
                }
                Label {
                    id: movePower
                    text: modelData.power ? modelData.power : qsTr("—")
                    width: 0.1 * parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    id: movePP
                    text: modelData.pp
                    width: 0.1 * parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                TypeBadge {
                    typeAbbr: modelData.type.identifier
                    typeName: modelData.type.name
                    width: 0.2 * parent.width
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

}
