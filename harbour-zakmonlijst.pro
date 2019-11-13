# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-zakmonlijst

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-zakmonlijst.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-zakmonlijst.changes.in \
    rpm/harbour-zakmonlijst.changes.run.in \
    rpm/harbour-zakmonlijst.spec \
    rpm/harbour-zakmonlijst.yaml \
    translations/*.ts \
    harbour-zakmonlijst.desktop \
    qml/pages/PokémonListPage.qml \
    qml/js/api.js \
    qml/pages/PokémonPage.qml \
    data/test.txt \
    qml/py/PokéApi.py \
    qml/data/database.sqlite \
    qml/pages/PokédexPage.qml \
    qml/cover/TypeBadge.qml \
    rpm/harbour-zakmonlijst.changes.run.in \
    rpm/harbour-zakmonlijst.spec \
    qml/cover/PokémonCoverPage.qml \
    qml/components/Evolution.qml \
    qml/components/ClickablePokémon.qml \
    qml/components/EvolutionPart.qml \
    qml/PokéApi.qml \
    qml/qmldir \
    qml/components/PokémonPicture.qml
    qml/sprites/*.png

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-zakmonlijst-de.ts

RESOURCES +=
