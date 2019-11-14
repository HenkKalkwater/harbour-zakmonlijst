import QtQuick 2.6
import Sailfish.Silica 1.0

// Load the PokéApi
import ".."
import "../components"

Page {
    id: pokémonPage

    property int pokémonId: 1
    property variant pokémon
    //property ListElement pokémon: undefined
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height


        VerticalScrollDecorator {}

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: pokémon ? pokémon.name : qsTr("Loading")
                Label {
                    id: genusLabel
                    width: parent.width - parent.leftMargin - parent.rightMargin
                    anchors {
                        top: parent._titleItem.bottom
                        right: parent.right
                        rightMargin: parent.rightMargin
                    }
                    text: pokémon ? pokémon.genus : ""
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

                PokémonPicture {
                    id: pokéPic
                    //source: if (pokémon) Qt.resolvedUrl("../sprites/" + pokémon.id + ".png")
                    height: width
                    no: pokémon ? pokémon.id : -1
                    fillMode: Image.PreserveAspectFit
                    width: parent.width / 2 - 2 * parent.leftPadding
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 2 - 2 * parent.rightPadding
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Repeater {
                            model: pokémon ? pokémon.types : 0
                            TypeBadge {
                                typeAbbr: modelData.identifier
                                typeName: modelData.name
                            }
                        }
                    }

                    DetailItem {
                        label: qsTr("Height")
                        value: pokémon ? (parseInt(pokémon.height) / 10) + "m" : qsTr("??? m")
                    }

                    DetailItem {
                        label: qsTr("Weight")
                        value: pokémon ? (parseInt(pokémon.weight) / 10) + " kg" : qsTr("??? kg")
                    }
                }
            }

            ExpandingSectionGroup {
                //currentIndex: 0
                ExpandingSection {
                    title: qsTr("Description")
                    content.sourceComponent: Label {
                        id: descriptionLabel
                        height: descriptionSpinner.running ? descriptionSpinner.height : implicitHeight;
                        Behavior on height {
                            NumberAnimation { duration: 100 }
                        }
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.rightMargin: Theme.horizontalPageMargin
                        anchors.right: parent.right
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: Theme.highlightColor
                        text: {
                            if (pokémon) {
                                if (pokémon.description) {
                                    return pokémon.description.replace("\n", " ")
                                } else {
                                    return qsTr("This Pokémon does not have a description for this game.")
                                }
                            } else {
                                return ""
                            }
                        }

                        BusyIndicator {
                            id: descriptionSpinner
                            anchors.centerIn: parent
                            running: descriptionLabel.text.length == 0
                            size: BusyIndicatorSize.Medium
                        }
                    }
                }

                ExpandingSection {
                    id: evolutionSection
                    title: qsTr("Evolution")
                    content.sourceComponent: Evolution {
                        enabled: evolutionSection.expanded
                        width: parent.width
                        pokémon: pokémonPage.pokémon
                     }
                 }
                ExpandingSection {
                    id: moveSection
                    title: qsTr("Moves")
                    content.sourceComponent: Column {
                        enabled: moveSection.expanded
                        spacing: Theme.paddingMedium
                        Repeater {
                            model: [
                                {"id": "levelUp", "description": qsTr("Learned by leveling up")},
                                {"id": "egg", "description": qsTr("Learnable via breeding")},
                                {"id": "tutor", "description": qsTr("Learnable via NPCs")},
                                {"id": "machine", "description": qsTr("Learnable via TMs and HMs")},
                                {"id": "formChange", "description": qsTr("Learnable via form change")}
                            ]
                            Column {
                                width: parent.width
                                visible: pokémonPage.pokémon.moves[modelData.id].length > 0
                                SectionHeader {
                                    text: modelData.description
                                }
                                MoveList {
                                  width: parent.width
                                  model: pokémonPage.pokémon.moves[modelData.id]
                                  showLvl: modelData.id == "levelUp"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active && pokémon) {
            window.coverMode = "pokémon"
            window.coverPokémon = pokémon
        }
    }

    Connections {
        target: PokéApi
        onPokémonLoaded: {
            if (id === pokémonId) {
                pokémonPage.pokémon = pokémon
                window.coverMode = "pokémon"
                window.coverPokémon = pokémon
            }
        }
    }

    Component.onCompleted: {
        PokéApi.requestPokémon(pokémonId)
    }

    /*Timer {
        running: true
        onTriggered: PokéApi.requestPokémon(pokémonId)
        interval: 1000
    }*/
}
