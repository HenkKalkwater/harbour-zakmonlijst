.pragma library

function PokéApi(baseUrl) {
    this.baseUrl = baseUrl || "https://pokeapi.co/api/v2/";
    this.pokémonList = [];
    this.pokémonModel = null;
}

/**
* Makes a request or loads the response from the cache, if it has been cached;
*/
PokéApi.prototype.request = function(path, callback) {
    var context = this;
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        if (request.readyState === 4 && request.status === 200) {
            callback(JSON.parse(request.response));
        } else if (request.readyState === 4) {
            console.debug("Status: " + request.statusText)
        }
    }
    request.open("GET", this.baseUrl + path, true);
    request.send();
}

PokéApi.prototype.loadPokémonList = function() {
    var context = this;
    this.request("pokemon/?limit=10000", function (response) {
        context.pokémonList = response.results;
        console.debug("Got Pokémon!");
        if (context.pokémonModel === null) return;
        var mId = 1;
        context.pokémonList.forEach(function(pokémon) {
            pokémon.id = mId;
            pokémon.expanded = false;
            pokémon.height = -1;
            pokémon.weight = -1;
            context.pokémonModel.append(pokémon);
            mId += 1;
        }, context);
        context.pokémonModel.sync();

    });
}

PokéApi.prototype.loadPokémon = function(id) {
    var context = this;
    console.debug("Fetching Pokémon " + id)
    this.request("pokemon/" + id + "/", function(response) {
        console.debug("Fetched Pokémon " + id)
        response.expanded = true;
        //response.id = id;
        context.pokémonModel.set(id - 1, response);
        context.pokémonModel.sync();
    });
}

PokéApi.prototype.setPokémonModel = function(model) {
    this.pokémonModel = model;
    console.log(model);
}

var mApi = new PokéApi();
var pokéModel = null;

WorkerScript.onMessage = function(message) {
    switch(message.type) {
    case "MODEL":
        switch(message.modelType) {
        case "POKÉMON_LIST":
            console.debug("Loading Pokémon...");
            console.log(message.model);
            mApi.setPokémonModel(message.model);
            mApi.loadPokémonList();
        }

        break;
    case "LOAD_POKÉMON":
        mApi.loadPokémon(message.id);
        break;
    }
}
