﻿#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sqlite3
import configparser
import pyotherside
import locale
import os
import time
import threading

# Setup sqlite
#TODO: remove hardcoded path
# We're never writing to the DB, so check_same_thread is unneeded.
cons = {}

def create_con():
    global cons
    ident = threading.get_ident()
    if not ident in cons:
        con = sqlite3.connect("file:///usr/share/harbour-zakmonlijst/qml/data/database.sqlite?immutable=1", uri=True);
        con.row_factory = sqlite3.Row
        cons[ident] = con
    return cons[ident]

def log(message):
    pyotherside.send("LOG", str(message))

# Initialise languages
try:
    # Get the current locale, access the first element, which is a language code
    # like 'en_US' and get the first part of it.
    preferred_language = locale.getlocale()[0].split("_")[0];
except AttributeError:
    # Sometimes locale.getlocale returns None?
    preferred_language = "en"
preferred_languages = {preferred_language, "en"}
preferred_language_id = 9

# CONFIG_PATH = os.environ.get("XDG_CONFIG_HOME") + "/harbour-zakmonlijst/config.cfg"
CONFIG_DIR = os.environ.get("HOME") + "/.config/harbour-zakmonlijst/"
CONFIG_PATH = CONFIG_DIR + "config.cfg"

pokédex = 1
game = 30
version_group_id = 1
generation = 8
typeMap = {}
gameMap = {}

def fetchPokémonDescription(id):
    global preferred_language_id
    global game
    c = create_con().cursor()
    c.execute('''SELECT psft.flavor_text
                 FROM pokemon_species_flavor_text AS psft
                 WHERE psft.species_id = ?
                       AND psft.version_id = ?
                       AND psft.language_id = ?''', (id, game, preferred_language_id))
    row = c.fetchone()
    if row is None:
        return None
    return row["flavor_text"]

def fetchPokémonMoves(id):
    global preferred_language_id
    global game
    c = create_con().cursor()
    result = {}
    typeMoves = ["levelUp", "egg", "tutor", "machine", "stadiumSurfingPikachu", "lightBallEgg",
        "colosseumPurification", "xdShadow", "xdPurification", "formChange"]
    result = {}
    for typeMove in typeMoves:
        result[typeMove] = []

    c.execute('''SELECT pm.move_id, mn.name, pm.level, m.power, m.pp, m.type_id, pm.pokemon_move_method_id AS move_method
                 FROM pokemon_moves AS pm
                 JOIN moves AS m ON m.id = pm.move_id
                 JOIN move_names AS mn ON mn.move_id = m.id
                 WHERE pm.pokemon_id = ? AND pm.version_group_id = ?
                    AND mn.local_language_id = ?
                 ORDER BY pm.level ASC, "pm.order" ASC''', (id, version_group_id, preferred_language_id))

    for row in c.fetchall():
        moveType = typeMoves[int(row["move_method"]) - 1]
        result[moveType].append({
            "id": row["move_id"],
            "name": row["name"],
            "level": row["level"],
            "power": row["power"],
            "pp": row["pp"],
            "type": typeMap[int(row["type_id"])]
        })
    log(result)
    return result

def fetchPokémon(id):
    global pokédex
    global preferred_language_id
    c = create_con().cursor()
    c.execute('''SELECT ps.id, psn.name, psn.genus, p.weight, p.height, GROUP_CONCAT(pt.type_id) AS types
                 FROM pokemon_species AS ps
                 JOIN pokemon_species_names AS psn ON ps.id = psn.pokemon_species_id
                                                  AND psn.local_language_id  = ?
                 JOIN pokemon AS p ON ps.id = p.species_id AND p.is_default = 1
                 JOIN pokemon_types AS pt ON pt.pokemon_id = p.species_id
                 WHERE ps.id=?
                 GROUP BY ps.id
                 ORDER BY pt.slot ASC''', (preferred_language_id, id));
    row = c.fetchone()
    typesTmp = row["types"].split(',')
    types = []
    for type in typesTmp:
        types.append(typeMap[int(type)])

    description = fetchPokémonDescription(id)
    evolutions = fetchEvolutionChain(id)
    moves = fetchPokémonMoves(id)

    return {
        # "index": row["id"],
        "id": row["id"],
        "name": row["name"],
        "genus": row["genus"],
        "weight": row["weight"],
        "height": row["height"],
        "types": types,
        "description": description,
        "evolutions": evolutions,
        "moves": moves

    }

def setGame(id):
    global game
    game = int(id)
    log(f"Game set to {game}")
    save()

def loadPokédex(id):
    global pokédex
    global preferred_language_id
    c = create_con().cursor()
    c.execute('''SELECT pdn.pokedex_number, ps.id, psn.name, psn.genus, p.weight, p.height, GROUP_CONCAT(pt.type_id) AS types
                 FROM pokemon_dex_numbers AS pdn
                 JOIN pokemon_species AS ps ON pdn.species_id = ps.id
                 JOIN pokemon_species_names AS psn ON ps.id = psn.pokemon_species_id
                                                  AND psn.local_language_id  = ?
                 JOIN pokemon AS p ON ps.id = p.species_id AND p.is_default = 1
                 JOIN pokemon_types AS pt ON pt.pokemon_id = p.species_id
                 WHERE pdn.pokedex_id=?
                 GROUP BY ps.id
                 ORDER BY pdn.pokedex_number ASC, pt.slot ASC''', (preferred_language_id, id));
    result = []
    i = 0
    for row in c.fetchall():
        typesTmp = row["types"].split(',')
        types = []
        for type in typesTmp:
            types.append(typeMap[int(type)])
        result.append({
            # "index": row["id"],
            "index": i,
            "id": row["id"],
            "pokedexNumber": row["pokedex_number"],
            "name": row["name"],
            "genus": row["genus"],
            "weight": row["weight"],
            "height": row["height"],
            "types": types
        });
        i += 1
    pokédex = int(id)
    save()
    return result

def createEvolutionObject(row):
    return {
        "name": row["pre_name"],
        "id": row["pre_id"],
        "evolution": {
            "name": row["ev_name"],
            "description": row["ev_desc"],
            "level": row["ev_lvl"],
            "happiness": row["ev_happiness"],
            "time": row["ev_time"]
        }
    }

def fetchEvolutionChain(id):
    global preferred_language_id
    SELECT_STRING = '''SELECT ps.id AS pre_id, psn.name AS pre_name,
    pe.minimum_level AS ev_lvl, etp.name AS ev_desc, et.identifier AS ev_name, pe.minimum_happiness AS ev_happiness,
    pe.time_of_day AS ev_time'''
    c = create_con().cursor()
    # Select pre-evolutions
    c.execute(SELECT_STRING + ''' FROM pokemon_evolution AS pe
                JOIN pokemon_species AS ps ON ps.id = (SELECT evolves_from_species_id FROM pokemon_species WHERE pe.evolved_species_id = id)
                JOIN pokemon_species_names AS psn ON psn.pokemon_species_id = ps.id
                                                     AND psn.local_language_id = ?
                JOIN evolution_triggers AS et ON et.id = pe.evolution_trigger_id
                JOIN evolution_trigger_prose AS etp ON pe.evolution_trigger_id = etp.evolution_trigger_id
                                                       AND etp.local_language_id = ?
                WHERE pe.evolved_species_id = ?
    ''', (preferred_language_id, preferred_language_id, id))
    result = {}
    prevolution = c.fetchone()
    if prevolution:
        result["prevolution"] = createEvolutionObject(prevolution)
    result["evolutions"] = []
    c.execute(SELECT_STRING + ''' FROM pokemon_evolution AS pe
                 JOIN pokemon_species AS ps ON ps.id = pe.evolved_species_id
                 JOIN pokemon_species_names AS psn ON psn.pokemon_species_id = ps.id
                                                      AND psn.local_language_id = ?
                 JOIN evolution_triggers AS et ON et.id = pe.evolution_trigger_id
                 JOIN evolution_trigger_prose AS etp ON pe.evolution_trigger_id = etp.evolution_trigger_id
                                                       AND etp.local_language_id = ?
                 WHERE ps.evolves_from_species_id = ?
    ''', (preferred_language_id, preferred_language_id, id))
    for row in c.fetchall():
        result["evolutions"].append(createEvolutionObject(row))
    return result

def initialise():
    global preferred_languages
    global preferred_language_id
    global version_group_id
    global game
    global typeMap
    global pokédex

    config = configparser.ConfigParser()
    config.read(CONFIG_PATH)
    game = int(config["DEFAULT"].get("game", "30"))
    pokédex = int(config["DEFAULT"].get("pokédex", "1"))

    # Try to find the preferred user language
    c = create_con().cursor();
    for language in preferred_languages:
        c.execute('''SELECT id
                     FROM languages
                     WHERE iso3166=?
                     ORDER BY "order"''', (language,))
        lang = c.fetchone()
        if lang:
            preferred_language_id = lang["id"];
            break;
    c.execute('''SELECT t.id, t.identifier, tn.name
                 FROM types AS t
                 JOIN type_names AS tn ON t.id = tn.type_id
                                       AND tn.local_language_id = ?''', (preferred_language_id,))
    # Send the types to QML
    i = 0
    for row in c.fetchall():
        typeMap[row["id"]] = {
                "index": i,
                "id": row["id"],
                "identifier": row["identifier"],
                "name": row["name"]
        }
        i += 1
    # And the pokédexes
    c.execute('''SELECT pokedex_id AS id, name, description
                 FROM pokedex_prose
                 WHERE local_language_id=?''', (preferred_language_id,))
    i = 0
    pokédexes = []
    for row in c.fetchall():
        pokédexes.append({
                "index": i,
                "id": row["id"],
                "name": row["name"],
                "description": row["description"]
        })
        i += 1
    pyotherside.send("POKÉDEX_SELECT", pokédex)

    # And the games
    c.execute('''SELECT v.id, vn.name, vg.generation_id, v.version_group_id
                FROM versions AS v
                JOIN version_names AS vn ON vn.version_id = v.id
                JOIN version_groups AS vg ON vg.id = v.version_group_id
                WHERE vn.local_language_id = ?''', (preferred_language_id,))
    i = 0
    games = []
    for row in c.fetchall():
        games.append({
            "index": i,
            "id": row["id"],
            "generation": row["generation_id"],
            "name": row["name"],
            "version_group_id": row["version_group_id"]
        })
        gameMap[int(row["id"])] = games[-1]

    version_group_id = gameMap[game]["version_group_id"]
    log(f"preferred_language_id: {preferred_language_id}")
    log(f"version_group_id: {version_group_id}")
    return (loadPokédex(pokédex), pokédexes, pokédex, games, game) #1: hardcoded reference to the national dex

def save():
    pass
    # saveBeforeExit()

def saveBeforeExit():
    global CONFIG_PATH
    global game
    global pokédex
    log("Exiting...")
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)

    config = configparser.ConfigParser()
    config["DEFAULT"] = {
        "game": game,
        "pokédex": pokédex
    }
    with open(CONFIG_PATH, "w") as configFile:
        config.write(configFile)

pyotherside.atexit(saveBeforeExit)
