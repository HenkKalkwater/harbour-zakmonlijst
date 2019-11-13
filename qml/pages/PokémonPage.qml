import QtQuick 2.6
import Sailfish.Silica 1.0

// Load the PokéApi
import ".."
import "../components"

Page {
    id: pokémonPage
    anchors.fill: parent

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
                    no: pokémon.id
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
            SectionHeader {
                text: qsTr("Description")
            }
            Label {
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
                            return pokémon.description.replace("/\n/g", " ")
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

            ExpandingSectionGroup {
                currentIndex: 0
                ExpandingSection {
                    title: qsTr("Evolution")
                    content.sourceComponent: Evolution {
                            width: parent.width
                            pokémon: pokémonPage.pokémon
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
