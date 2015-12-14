/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the ZcPostIt application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* ZcPostIt is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

import ZcClient 1.0 as Zc
import "../Components" as PiComponents
import QtMultimedia 5.4

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    property string audioTmpFileName : ""

    PiComponents.ToolBar
    {
        id : toolbarBoard

        anchors {
            right: parent.right
            left: parent.left
            top: parent.top
            topMargin : 1
        }

        Row {
            id : toolBarId
            anchors.fill: parent

            ToolButton {
                onClicked: {
                }
            }
        }
    }



    PiComponents.ActionList {
        id: contextualMenu

        Action {
            text: qsTr("Edit")
            onTriggered: {
            }
        }
    }


    menuActions :
        [
        Action {
            id: closeAction
            text:  "Close TalkingBoard"
            onTriggered:
            {
                Qt.inputMethod.hide();
                mainView.closeTask();
            }
        }
        ,
        Action {
            id: recordAction
            text:  "record"
            onTriggered:
            {
                //audioRecorder.outputFileLocation = "D:/tmp/toto.wav";
                audioRecorder.outputFileLocation = audioTmpFileName
                audioRecorder.record();
            }
        }
        ,
        Action {
            id: stop
            text:  "stop"
            onTriggered:
            {
                console.log(">> stop")
                audioRecorder.stop();
            }
        }
        ,
        Action {
            id: play
            text:  "play"
            onTriggered:
            {
                //playMusic.source =  "D:/tmp/toto.wav"
                playMusic.source = audioTmpFileName
                playMusic.play()
            }
        }
        ,
        Action {
            id: clear
            text:  "clear"
            onTriggered:
            {
                playMusic.stop();
                playMusic.source = "bidon"
                //audioRecorder.outputFileLocation = "D:/tmp/toto.wav";
                audioRecorder.outputFileLocation = audioTmpFileName
                audioRecorder.clear()
            }
        }
    ]

    function generateId()
    {
        var d = new Date();
        return mainView.context.nickname + "|" + d.toLocaleDateString() + "_" + d.toLocaleTimeString() + " " + d.getMilliseconds();
    }

    Zc.AudioRecorder {

        id : audioRecorder
    }

    FileDialog {
        id : chooseFolder
        selectFolder: true

        folder : shortcuts.documents

        onAccepted:
        {
        }
    }

    Audio {
            id: playMusic
            onStopped: {
                console.log(">> on stopped")
                source =  ""
            }
        }

    Zc.CrowdActivity
    {
        id : activity

        Zc.AppNotification
        {
            id : appNotification
        }

        onStarted :
        {
        }

    }

    onLoaded :
    {
        activity.start();
        audioTmpFileName = mainView.context.temporaryPath + "/audio.wav";
        console.log(">> audioTmpFileName " + audioTmpFileName)
    }

    onClosed :
    {
        activity.stop();
    }


}
