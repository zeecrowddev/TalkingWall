import QtQuick 2.0

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4

import ZcClient 1.0 as Zc

ProgressBarStyle {
        background: Image {
            source: "../Resources/sound.jpg"
            width: 200
            height: 40
        }
        progress: Rectangle {
            color: "lightsteelblue"
            border.color: "steelblue"
        }
    }

