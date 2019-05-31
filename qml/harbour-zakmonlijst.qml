import QtQuick 2.6
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import "pages"

ApplicationWindow
{
    id: window;
    property int currentPokédex
    ListModel {
        id: pokémonList
        //dynamicRoles: true;
    }

    ListModel {
        id: typesList
        //dynamicRoles: true
        property var map: []
    }

    ListModel {
        id: versionList
    }

    ListModel {
        id: pokédexesList
    }


    initialPage: Component { PokémonListPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    /* WorkerScript {
        id: pokéApi
        source: "js/api.js"
        function loadList() {
            console.log(pokémonList);
            pokéApi.sendMessage({
                    "type": "MODEL",
                    "modelType": "POKÉMON_LIST",
                    "model": pokémonList
                });
        }

        function requestPokémon(id) {
            pokéApi.sendMessage({
                    "type": "LOAD_POKÉMON",
                    "id": id
                });
        }
    } */
    Python {
        id: pokéApi
        function loadList() {}
        function requestPokémon(id) {}
        function requestPokémonDescription(id, callback) {
            call("PokéApi.fetchPokémonDescription", [id, 18], callback)
        }
        function loadPokédex(id) {
            call("PokéApi.loadPokédex", [id], function(){})
        }
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("py/"))
            importModule("PokéApi", function() {})
            setHandler("POKÉMON_MODEL_SET", function(data) {
                pokémonList.set(data.index, data);
            });
            setHandler("POKÉMON_MODEL_RESET", function() {
                pokémonList.clear()
            })
            setHandler("TYPES_MODEL_SET", function(data) {
                typesList.set(data.index, data);
                typesList.map[data.id] = data;
            })
            setHandler("POKÉDEXES_MODEL_SET", function(data){
                pokédexesList.set(data.index, data);
            });
            call("PokéApi.initialise", function(){})
        }
    }
}
