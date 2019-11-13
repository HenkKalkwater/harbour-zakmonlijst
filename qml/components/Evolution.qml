import QtQuick 2.6
import Sailfish.Silica 1.0

import ".."

Column {
    id: evolution
    property var pokémon
    property var prevolution: if(pokémon) pokémon.evolutions.prevolution
    property var evolutions: if(pokémon) pokémon.evolutions.evolutions
    topPadding: Theme.paddingMedium
    bottomPadding: Theme.paddingMedium

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("This pokémon has no evolutions")
        color: Theme.highlightColor
        visible: pokémon != null && !prevolution && (!evolutions || evolutions.length === 0)
    }

    BusyIndicator {
        running: !pokémon
        anchors.horizontalCenter: parent.horizontalCenter
        visible: running
    }

    EvolutionPart {
        visible: prevolution !== undefined
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
}
