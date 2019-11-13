import QtQuick 2.6
import Sailfish.Silica 1.0

import ".."

Column {
    id: evolution
    property var pokémon
    property var _prevolution: if(pokémon) pokémon.evolutions.prevolution
    property var _evolutions: if(pokémon) pokémon.evolutions.evolutions
    topPadding: Theme.paddingMedium
    bottomPadding: Theme.paddingMedium

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("This pokémon has no evolutions")
        color: Theme.highlightColor
        visible: pokémon != null && !_prevolution && (!_evolutions || _evolutions.length === 0)
    }

    BusyIndicator {
        running: !pokémon
        anchors.horizontalCenter: parent.horizontalCenter
        visible: running
    }

    EvolutionPart {
        visible: _prevolution !== undefined
        from: _prevolution
        to: pokémon
        evolution: _prevolution.evolution
    }

    Repeater {
        model: _evolutions
        delegate: EvolutionPart {
            from: pokémon
            to: model.modelData
            evolution: model.modelData.evolution
        }
    }
}
