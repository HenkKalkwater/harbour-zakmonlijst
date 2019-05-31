#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sqlite3
import pyotherside
import locale
import time

con = sqlite3.connect("/usr/share/harbour-zakmonlijst/qml/data/database.sqlite");
con.row_factory = sqlite3.Row

try:
    # Get the current locale, access the first element, which is a language code
    # like 'en_US' and get the first part of it.
    preferred_language = locale.getlocale()[0].split("_")[0];
except AttributeError:
    # Sometimes locale.getlocale returns None?
    preferred_language = "en"
preferred_languages = {preferred_language, "en"}
preferred_language_id = 9

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

def initialise():
    c = con.cursor();
    global preferred_languages
    global preferred_language_id
    for language in preferred_languages:
        c.execute('''SELECT id
                     FROM languages
                     WHERE iso3166=?
                     ORDER BY "order"''', (language,))
        if c.rowcount > 0:
            preferred_language_id = c.fetchone()["id"];
            break;
    c.execute('''SELECT t.id, t.identifier, tn.name
                 FROM types AS t
                 JOIN type_names AS tn ON t.id = tn.type_id
                                       AND tn.local_language_id = ?''', (preferred_language_id,))
    i = 0
    for row in c.fetchall():
        pyotherside.send("TYPES_MODEL_SET", {
                "index": i,
                "id": row["id"],
                "identifier": row["identifier"],
                "name": row["name"]
        })
        i += 1
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
    print(f"preferred_language_id: {preferred_language_id}")
    loadPokédex(1) #1: hardcoded reference to the national dex
