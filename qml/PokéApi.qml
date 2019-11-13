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

    property int pokédexIndex: 0

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

    readonly property Python otherSide: Python {
        function initialise() {
            console.info("Loading PokéApi")
            addImportPath(Qt.resolvedUrl("py/"))
            importModule("PokéApi", function(success) {})

            setHandler("LOG", function(data) { console.debug("Python: " + data); })

            call("PokéApi.initialise", [], function(result){
                var pokémons = result[0]
                var pokédexes = result[1]
                console.debug("Pokémon loaded")
                for (var i = 0; i < pokémons.length; i++) {
                    pokédexModel.append(pokémons[i])
                }

                for (i = 0; i < pokédexes.length; i++) {
                    pokédexesModel.append(pokédexes[i])
                    console.log(JSON.stringify(pokédexes[i]))
                    console.log(pokédexesModel.get(i))
                }
            })

        }
    }

    function initialise() { otherSide.initialise(); }
}
