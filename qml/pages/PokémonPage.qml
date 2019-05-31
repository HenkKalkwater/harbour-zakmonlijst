import QtQuick 2.6
import Sailfish.Silica 1.0

import "../components"

Page {
    id: pokémonPage
    anchors.fill: parent

    property variant pokémon
    //property ListElement pokémon: undefined
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: pokémon.name
                Label {
                    id: genusLabel
                    width: parent.width - parent.leftMargin - parent.rightMargin
                    anchors {
                        top: parent._titleItem.bottom
                        right: parent.right
                        rightMargin: parent.rightMargin
                    }
                    text: pokémon.genus
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                    opacity: 0.8
                    horizontalAlignment: Text.AlignRight
                    truncationMode: TruncationMode.Fade
                }
            }

            Row {
                id: basicSection
                height: pokéPic.height
                width: parent.width
                leftPadding: Theme.horizontalPageMargin
                rightPadding: Theme.horizontalPageMargin

                Image {
                    id: pokéPic
                    source: Qt.resolvedUrl("../sprites/" + pokémon.id + ".png")
                    height: width
                    fillMode: Image.PreserveAspectFit
                    width: parent.width / 2 - 2 * parent.leftPadding
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 2 - 2 * parent.rightPadding
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Repeater {
                            model: pokémon.types
                            TypeBadge {
                                typeAbbr: typesList.map[model.id].identifier
                                typeName: typesList.map[model.id].name
                            }
                        }
                    }

                    DetailItem {
                        label: qsTr("Height")
                        value: (parseInt(pokémon.height) / 10) + " m";
                    }

                    DetailItem {
                        label: qsTr("Weight")
                        value: (parseInt(pokémon.weight) / 10) + " kg"
                    }
                }
            }
            SectionHeader {
                text: qsTr("Description")
            }
            Label {
                id: descriptionLabel
                height: descriptionSpinner.running ? descriptionSpinner.height : implicitHeight;
                Behavior on height {
                    NumberAnimation { duration: 100 }
                }
                width: parent.width
                leftPadding: Theme.horizontalPageMargin
                rightPadding: Theme.horizontalPageMargin

                Component.onCompleted: {
                    pokéApi.requestPokémonDescription(pokémon.id, function(response) {
                        text = response
                    })
                }

                BusyIndicator {
                    id: descriptionSpinner
                    anchors.centerIn: parent
                    running: descriptionLabel.text.length == 0
                    size: BusyIndicatorSize.Medium
                }
            }

            ExpandingSectionGroup {
                currentIndex: 0
                ExpandingSection {
                    title: qsTr("Evolution")
                    content.sourceComponent: Column {
                        Label {
                            text: "TODO"
                        }
                     }
                 }
                ExpandingSection {
                    title: qsTr("Moves")
                    content.sourceComponent: Column {
                        Label {
                            text: "Also TODO"
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: if(!pokémon.expanded) pokéApi.requestPokémon(pokémon.id)
}
