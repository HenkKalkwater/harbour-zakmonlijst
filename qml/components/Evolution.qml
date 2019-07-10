import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    id: evolution
    property var pokémon
    property var prevolution
    property var evolutions
    topPadding: Theme.paddingMedium
    bottomPadding: Theme.paddingMedium

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("This pokémon has no evolutions")
        color: Theme.highlightColor
        visible: prevolution == null && evolutions.count == 0
    }

    EvolutionPart {
        visible: prevolution != null
        from: prevolution
        to: pokémon
        evolution: prevolution.evolution
    }

    Repeater {
        model: evolutions
        delegate: EvolutionPart {
            from: pokémon
            to: model.modelData
            evolution: model.modelData.evolution
        }
    }

    Component.onCompleted: {
        pokéApi.requestPokémonEvolution(pokémon.id, function(result) {
            console.log(JSON.stringify(result))
            if (result.prevolution != null) {
                evolution.prevolution = result.prevolution
            }
            evolution.evolutions = result.evolutions
        })
    }
}
