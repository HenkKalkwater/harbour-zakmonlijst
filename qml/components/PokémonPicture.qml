import QtQuick 2.6
import Sailfish.Silica 1.0

Image {
    id: pokémonPicture
    property int no: -1
    fillMode: Image.PreserveAspectFit

    Image {
        id: errorPicture
        fillMode: Image.Pad
        anchors.fill: parent
    }

    states: [
        State {
            name: "loading"
            when: no == -1
            PropertyChanges {
                target: errorPicture
                source: "image://theme/icon-m-question"
            }
            PropertyChanges {
                target: pokémonPicture
            }
        },
        State {
            name: "error"
            when: pokémonPicture.status == Image.Error
            PropertyChanges {
                target: errorPicture
                source: "image://theme/icon-s-warning"
            }
            PropertyChanges {
                target: pokémonPicture
            }
        },
        State {
            name: ""
            PropertyChanges {
                target: pokémonPicture
                source: Qt.resolvedUrl("../sprites/" + no + ".png")
            }
            PropertyChanges {
                target: errorPicture
            }
        }
    ]
    /*transitions: [
        Transition {
            from: "*"
            to: "*"

            FadeAnimation {
                targets: [pokémonPicture, errorPicture]
                properties: "opacity"
            }
        }
    ]*/
}
