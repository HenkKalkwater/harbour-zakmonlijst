pragma Singleton
import QtQuick 2.2
import io.thp.pyotherside 1.4

Item {
    id: api
    // Contains all pokémon, in national dex order
    readonly property ListModel pokémonModel: ListModel {}
    // The model that represents the Pokémon inside the currently selected Pokédex
    readonly property ListModel pokédexModel: ListModel {}
    // Contains the list of pokédexes
    readonly property ListModel pokédexesModel: ListModel {}
    readonly property ListModel gamesModel: ListModel {}

    property int pokédexIndex: 0
    property int gameIndex: 0

    // Signal fired when a pokémon has been loaded
    signal pokémonLoaded(int id, var pokémon)

    function requestPokémon(id) {
        otherSide.call("PokéApi.fetchPokémon", [id], function (pokémon) {
            console.debug("id: " + id + ", pokémon: " + JSON.stringify(pokémon))
            api.pokémonLoaded(id, pokémon)
        })
    }

    function loadPokédex(idx) {
        pokédexIndex = idx
        var id = pokédexesModel.get(idx).id
        console.debug("Loading Pokédex " + id)
        otherSide.call("PokéApi.loadPokédex", [id], function(pokémons) {
            pokédexModel.clear()
            for (var i = 0; i < pokémons.length; i++) {
                pokédexModel.append(pokémons[i])
            }
        })
    }

    function setGame(idx) {
        gameIndex = idx
        var id = gamesModel.get(idx).id
        otherSide.call("PokéApi.setGame", [id], function(){})
    }

    readonly property Python otherSide: Python {
        function initialise() {
            console.info("Loading PokéApi")
            addImportPath(Qt.resolvedUrl("py/"))
            importModule("PokéApi", function(success) {})

            setHandler("LOG", function(data) { console.debug("Python: " + data); })

            call("PokéApi.initialise", [], function(result){
                var pokémons = result[0]
                var pokédexes = result[1]
                var pokédex = result[2]
                var games = result[3]
                var game = result[4]

                console.debug("Pokémon loaded")
                for (var i = 0; i < pokémons.length; i++) {
                    pokédexModel.append(pokémons[i])
                }

                for (i = 0; i < pokédexes.length; i++) {
                    pokédexesModel.append(pokédexes[i])
                    if (pokédexes[i].id === pokédex) pokédex = i
                }

                for (i = 0; i < games.length; i++) {
                    gamesModel.append(games[i])
                    if (games[i].id === game) gameIndex = i
                }

            })

        }
    }

    function initialise() { otherSide.initialise(); }
}
