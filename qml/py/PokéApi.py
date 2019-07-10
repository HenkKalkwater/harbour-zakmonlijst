﻿#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sqlite3
import configparser
import pyotherside
import locale
import os
import time

# Setup sqlite
con = sqlite3.connect("/usr/share/harbour-zakmonlijst/qml/data/database.sqlite");
con.row_factory = sqlite3.Row

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
CONFIG_PATH = os.environ.get("HOME") + "/.config/harbour-zakmonlijst/config.cfg"

pokédex = 1
game = 30
generation = 8

def fetchPokémonDescription(id, gameId):
    global preferred_language_id
    c = con.cursor()
    c.execute('''SELECT psft.flavor_text
                 FROM pokemon_species_flavor_text AS psft
                 WHERE psft.species_id = ?
                       AND psft.version_id = ?
                       AND psft.language_id = ?''', (id, gameId, preferred_language_id))
    return c.fetchone()["flavor_text"]

def loadPokédex(id):
    global pokédex
    global preferred_language_id
    c = con.cursor()
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
    pyotherside.send("POKÉMON_MODEL_RESET")
    i = 0
    for row in c.fetchall():
        typesTmp = row["types"].split(',')
        types = []
        for type in typesTmp:
            types.append({"id": int(type)})
        pyotherside.send("POKÉMON_MODEL_SET", {
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
    pyotherside.send("POKÉDEX_LOADED", id)
    pokédex = id

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
    c = con.cursor()
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
    log(result)
    return result

def initialise():
    global preferred_languages
    global preferred_language_id
    global game
    global pokédex

    config = configparser.ConfigParser()
    config.read(CONFIG_PATH)
    game = int(config["DEFAULT"].get("game", "30"))
    pokédex = int(config["DEFAULT"].get("pokédex", "1"))

    # Try to find the preferred user language
    c = con.cursor();
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
        pyotherside.send("TYPES_MODEL_SET", {
                "index": i,
                "id": row["id"],
                "identifier": row["identifier"],
                "name": row["name"]
        })
        i += 1
    # And the pokédexes
    c.execute('''SELECT pokedex_id AS id, name, description
                 FROM pokedex_prose
                 WHERE local_language_id=?''', (preferred_language_id,))
    i = 0
    for row in c.fetchall():
        pyotherside.send("POKÉDEXES_MODEL_SET", {
                "index": i,
                "id": row["id"],
                "name": row["name"],
                "description": row["description"]
        })
        i += 1
    pyotherside.send("POKÉDEX_SELECT", pokédex)
    log(f"preferred_language_id: {preferred_language_id}")
    loadPokédex(pokédex) #1: hardcoded reference to the national dex

def saveBeforeExit():
    global CONFIG_PATH
    global game
    global pokédex
    log("Exiting...")
    config = configparser.ConfigParser()
    config["DEFAULT"] = {
        "game": game,
        "pokédex": pokédex
    }
    with open(CONFIG_PATH, "w") as configFile:
        config.write(configFile)

pyotherside.atexit(saveBeforeExit)
