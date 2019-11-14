import QtQuick 2.6
import Sailfish.Silica 1.0;

import ".."
import "../components"

Page {
    id: pokémonListPage
    //anchors.fill: parent
    allowedOrientations: Orientation.All

    SilicaListView {
        anchors.fill: parent
        header: Column {
            property alias searchActive: pokéSearch.active
            width: parent.width
            PageHeader {
                title: qsTr("Pokémon List")
            }
            SearchField {
                id: pokéSearch
                width: parent.width
                EnterKey.onClicked: Qt.inputMethod.hide()
            }
        }

        cacheBuffer: Theme.paddingMedium * 5
        model: PokéApi.pokédexModel
        delegate: PokémonDelegate {
            onPokémonClicked: pageStack.push(Qt.resolvedUrl("PokémonPage.qml"), {"pokémonId": model.id})
        }
        VerticalScrollDecorator {}
    }
    onStatusChanged: {
        switch(status) {
        case PageStatus.Activating:
            window.coverMode = "default";
            break;
        case PageStatus.Active:
            // QML has some weird bugs
            pageStack.pushAttached(Qt.resolvedUrl("PokédexPage.qml"), {
                                       "pokédexModel": PokéApi.pokédexesModel,
                                       "changePokédex": PokéApi.loadPokédex,
                                       "currentPokédex": PokéApi.pokédexIndex,
                                       "gamesModel": PokéApi.gamesModel,
                                       "changeGame": PokéApi.setGame,
                                       "currentGame": PokéApi.gameIndex
                                   })
            break;
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: PokéApi.pokédexModel.count === 0
        size: BusyIndicatorSize.Large
    }
}
