import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property var from
    property var to
    property var evolution

    id: evolutionPart
    height: Math.max(evolutionPreClick.height, evolutionPostClick.height)
    //width: evolutionPreClick.width + evolveArrowContainer.width
           //+ evolutionPostClick.width + 2 * Theme.paddingMedium
    anchors.left: parent.left
    anchors.right: parent.right
    // Prevolution
    ClickablePokémon {
        id: evolutionPreClick
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: evolveArrowContainer.left
        anchors.rightMargin: Theme.paddingMedium
        pokémon: evolutionPart.from
    }
    Column {
        id: evolveArrowContainer
        anchors.centerIn: parent
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://theme/icon-m-forward"
        }
        Label {
            text: {
                var additionalRequirements = []
                if (evolution.happiness !== "") {
                    additionalRequirements.push(qsTr("with happiness > %1").arg(evolution.happiness))
                }
                if (evolution.time !== "") {
                    if (evolution.time === "day") {
                        //: The time an evolution should occur
                        additionalRequirements.push(qsTr("at day"))
                    } else {
                        //: The time an evolution should occur
                        additionalRequirements.push(qsTr("at night"))
                    }
                }

                var additionalRequirementsString = additionalRequirements.length > 0
                    ? "\n" + additionalRequirements.join("\n")
                    : "";
                switch (evolution.name) {
                case "level-up":
                    if (evolution.level === "") {
                        return qsTr("by leveling up%1").arg(additionalRequirementsString)
                    }
                    //: The level the Pokémon evolves at, shown under an arrow indicating evolution
                    return qsTr("at level %1%2").arg(evolution.level).arg(additionalRequirementsString)
                case "use-item":
                    //: Item used to evolve the Pokémon
                    return qsTr("use %1%2").arg("<item>").arg(additionalRequirementsString)
                default:
                    return "evolve"
                }
            }
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
        }
    }
    ClickablePokémon {
        id: evolutionPostClick
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: evolveArrowContainer.right
        anchors.leftMargin: Theme.paddingMedium
        pokémon: evolutionPart.to
    }
}
