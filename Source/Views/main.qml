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

    property var currentFileDescriptor : null

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

        property var fileDescriptor : null

        Action {
            text: qsTr("Delete")
            onTriggered: {
                console.log(">> contextualMenu.fileDescriptor " + contextualMenu.fileDescriptor)
                crowdDocumentFolder.deleteFile(contextualMenu.fileDescriptor)
            }
        }
        Action {
            text: qsTr("Play")
            onTriggered: {
                var name = contextualMenu.fileDescriptor.name;
                console.log(">> name " + name)
                var nameWav = contextualMenu.fileDescriptor.name.replace(".jpg",".wav");
                console.log(">> nameWav " + nameWav)
                var url = crowdDocumentFolder.getUrlFromFileName(name);
                console.log(">> url " + url)
                url = url.replace(name,"sounds/" + nameWav);
                console.log(">> url to play " + url)

                /*

                var to = "";

                if (Qt.platform.os  == "ios") {
                    crowdDocumentFolder.localPath = Zc.HostInfo.writableLocation(7) //+ "/listen.wav";
                } else if (Qt.platform.os  == "android") {
                    crowdDocumentFolder.localPath =  Zc.HostInfo.writableLocation(4) //+ "/listen.wav";
                } else {
                    crowdDocumentFolder.localPath = Zc.HostInfo.writableLocation(7) //+ "/listen.wav";
                }
                var fd = crowdDocumentFolder.getFileDescriptor(contextualMenu.fileDescriptor.name,false)
                documentFolderId.ensureLocalPathExists("sounds");
                console.log('>> fd ' + fd)
                fd.name = "sounds/" +nameWav;

                crowdDocumentFolder

                var res = crowdDocumentFolder.downloadFileTo(fd,to);

                console.log(">> res " + res)
                playMusic.source = url;

            //    playMusic.source = "http://www.wavsource.com/snds_2015-12-13_4694675918641206/movie_stars/bogart/down_to_cases.wav"

                playMusic.play();
                */

                var to = "";

                if (Qt.platform.os  == "ios") {
                    to = Zc.HostInfo.writableLocation(7) + "/listen.wav";
                } else if (Qt.platform.os  == "android") {
                    to  =  Zc.HostInfo.writableLocation(4) + "/listen.wav";
                } else {
                    to = Zc.HostInfo.writableLocation(7) + "/listen.wav";
                }

                console.log(">> to ")

                var result =  crowdSharedResource.downloadFileTo("sounds/" + nameWav,to,downloadFileQueryId);

                console.log(">> result " + result)

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

                //textArea.text = textArea.text + "audioRecorder.outputFileLocation " + audioRecorder.outputFileLocation + "\n"

                audioRecorder.stop();
            }
        }
        ,
        Action {
            id: play
            text:  "play"
            onTriggered: {
                if (Qt.platform.os  == "ios") {
                    playMusic.source = "file:/" + audioTmpFileName
                } else if (Qt.platform.os  == "android") {
                    playMusic.source = "file://" + audioTmpFileName + ".mp4"
                } else {
                    playMusic.source = audioTmpFileName
                }

                //textArea.text = textArea.text + "playMusic.source" + playMusic.source + "\n"

                console.log(">> playMusic.source " + playMusic.source)

                playMusic.source = "http://www.wavsource.com/snds_2015-12-13_4694675918641206/movie_stars/bogart/down_to_cases.wav"

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
                audioRecorder.outputFileLocation = audioTmpFileName
                audioRecorder.clear()
            }
        }
        ,
        Action {
            id: addNew
            text:  "Add"
            onTriggered: {
                cameraLoader.visible = true
                cameraLoader.sourceComponent = cameraViewComponent
                cameraLoader.item.open()
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

        Zc.MessageSender
        {
            id      : notifySender
            subject : "notify"
        }

        Zc.MessageListener
        {
            id      : notifyListener
            subject : "notify"

            onMessageReceived :
            {
                console.log(">> message.body " + message.body)

                var o = JSON.parse(message.body);

                if ( o !==null )
                {

                    appNotification.blink();
                    if (!mainView.isCurrentView)
                    {
                        appNotification.incrementNotification();
                    }

                    if ( o.action === "deleted" )
                    {
                        crowdDocumentFolder.removeFileDescriptor(o.fileName)
                    }
                    else if (o.action === "added")
                    {
                        var fd = crowdDocumentFolder.getFileDescriptor(o.fileName,true);
                        fd.setRemoteInfo(o.size,new Date(o.lastModified));
                    }
                }

            }
        }

        Zc.CrowdSharedResource
        {
            id   : crowdSharedResource
            name : "TalkingWallFolder"

            Zc.StorageQueryStatus
            {
                id : downloadFileQueryId

                onCompleted : {

                    console.log(">> Download completetd")
                    var to = "";

                    if (Qt.platform.os  == "ios") {
                        to = Zc.HostInfo.writableLocation(7) + "/listen.wav";
                    } else if (Qt.platform.os  == "android") {
                        to  =  Zc.HostInfo.writableLocation(4) + "/listen.wav";
                    } else {
                        to = Zc.HostInfo.writableLocation(7) + "/listen.wav";
                    }

                    if (Qt.platform.os  == "ios") {
                        playMusic.source = "file:/" + to
                    } else if (Qt.platform.os  == "android") {
                        playMusic.source = "file://" + to
                    } else {
                        playMusic.source = to
                    }


                    playMusic.source = to
                    console.log(">> playMusic.source " + playMusic.source)

                    playMusic.play()


                }

            }

        }


        Zc.CrowdDocumentFolder
        {
            id   : crowdDocumentFolder
            name : "talkingWallFiles"


            Zc.QueryStatus
            {
                id : documentFolderQueryStatus

                onErrorOccured :
                {
                    console.log(">> ERRROR OCCURED")
                }

                onCompleted :
                {

                    console.log(">> crowdDocumentFolder.count " + crowdDocumentFolder.count)
                }
            }

            /*
            onFileDownloaded : {
                console.log(">> fileName " + fileName)
                console.log(">> localFilePath " + localFilePath)

                if (Qt.platform.os  == "ios") {
                    playMusic.source = "file:/" + localFilePath
                } else if (Qt.platform.os  == "android") {
                    playMusic.source = "file://" + localFilePath
                } else {
                    playMusic.source = localFilePath
                }
                 playMusic.play()
            }*/


            onFileUploaded : {
                appNotification.logEvent(Zc.AppNotification.Add,"File",fileName,"image://icons/" + "file:///" + fileName)
                notifySender.sendMessage("","{ \"action\" : \"added\" , \"fileName\" : \"" + fileName + "\" , \"lastModified\" : \"" + currentFileDescriptor.timeStamp + "\" }");
            }

            onFileDeleted : {
                notifySender.sendMessage("","{ \"action\" : \"deleted\" , \"fileName\" : \"" + fileName + "\" } ");
            }

        }

        onStarted :
        {
            grid.model = crowdDocumentFolder.files
            crowdDocumentFolder.loadRemoteFiles(documentFolderQueryStatus);
        }
    }


    Rectangle {
        anchors.fill: parent
        color : "white"
    }
    /*

    TextArea
    {
        id :textArea
        anchors.fill: parent
        text : "Test"
    }*/


    GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: Zc.AppStyleSheet.width(0.01)

        boundsBehavior: Flickable.StopAtBounds

        cellWidth: Zc.AppStyleSheet.adjustSubdivisionSizeX(width, 2, -1, 1.5)
        cellHeight: cellWidth*5/4
        clip: true
        delegate: /*CrowdDelegate {
            iconUrl: crowdModel === null
                ? ""
                : rootObject.host.services.crowdService
                    .getCrowdResourceUrl(crowdModel, "icon.png")

            onPressAndHold: showContextMenu(crowdModel)

            onClicked: {
                if (!crowdModel.crowdDestroyed) {
                    rootObject.services.viewService.showCrowdPage(crowdModel);
                } else {
                    crowds.leaveADestroyedCrowd(crowdModel)
                }
            }*/
                  Item{
            width: GridView.view.cellWidth - 2
            height: GridView.view.cellHeight - 2
            Rectangle {
                anchors.fill: parent
                color : "lightgrey"
            }

            Image {
                id : imageId
                source : crowdDocumentFolder.getUrlFromFileName(name);
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                onStatusChanged:
                {
                    if (status != Image.Error )
                    {
                        messageTextId.visible = false
                        messageTextId.text = "";
                    }
                    else
                    {
                        messageTextId.visible = false
                        messageTextId.text = "Error"
                    }

                }

                onProgressChanged:
                {
                    if ( status === Image.Loading)
                    {
                        messageTextId.text = Math.round(imageId.progress * 100) + "%"
                        messageTextId.visible = true
                    }
                }
                Text
                {
                    id : messageTextId
                    anchors.centerIn : parent
                    color : "black"
                    text : "Loading ..."
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        contextualMenu.fileDescriptor = item
                        contextualMenu.show()
                    }
                }

            }
        }
    }

    Loader {
        id : cameraLoader
        visible : false

        anchors.fill : parent
    }

    Component {

        id : cameraViewComponent

        CameraView {
            id : cameraView
            visible : false

            onValidated : {
                var fdSound = crowdDocumentFolder.createFileDescriptorFromFile(cameraLoader.item.audioTmpFileName);
                var fdImage = crowdDocumentFolder.createFileDescriptorFromFile(cameraLoader.item.path);

                console.log(">> cameraLoader.item.path "  + cameraLoader.item.path)
                console.log(">> fdSound " + fdSound)

                if (fdSound !== null)
                {
                    // ATTENTION REVOIRE CELA POUR LES DEVICE
                    fdSound.name = "sounds/"+ fdImage.name.replace(".jpg",".wav")
                    console.log(">> fdSound.path " + fdSound.name)
                    crowdDocumentFolder.localPath = "";
                    currentFileDescriptor = fdSound;
                    var result = crowdDocumentFolder.uploadFile(fdSound,cameraLoader.item.audioTmpFileName)
                    console.log(">> result : " + result)
                }


                console.log(">> cameraLoader.item.path "  + cameraLoader.item.path)
                console.log(">> fdImage " + fdImage)

                if (fdImage !== null)
                {
                    console.log(">> fdImage.path " + fdImage.name)
                    crowdDocumentFolder.localPath = "";
                    currentFileDescriptor = fdImage;
                    result = crowdDocumentFolder.uploadFile(fdImage,cameraLoader.item.path)
                    console.log(">> result : " + result)
                }


                cameraLoader.item.close()
                cameraLoader.sourceComponent = undefined
                cameraLoader.visible = false
            }
        }
    }

    onLoaded : {
        activity.start();

        if (Qt.platform.os  == "ios") {
            audioTmpFileName = Zc.HostInfo.writableLocation(7) + "/audio.wav";
        } else if (Qt.platform.os  == "android") {
            audioTmpFileName = Zc.HostInfo.writableLocation(4) + "/audio";
        } else {
            audioTmpFileName = Zc.HostInfo.writableLocation(7) + "/audio.wav";
        }

        console.log(">> audioTmpFileName " + audioTmpFileName)
        /* textArea.text = textArea.text + ">> audioTmpFileName " + audioTmpFileName  + "\n"
        textArea.text = textArea.text + "-------------------------\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(0)" + Zc.HostInfo.writableLocation(0) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(1)" + Zc.HostInfo.writableLocation(1) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(2)" + Zc.HostInfo.writableLocation(2) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(3)" + Zc.HostInfo.writableLocation(3) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(4)" + Zc.HostInfo.writableLocation(4) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(5)" + Zc.HostInfo.writableLocation(5) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(6)" + Zc.HostInfo.writableLocation(6) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(7)" + Zc.HostInfo.writableLocation(7) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(8)" + Zc.HostInfo.writableLocation(8) + "\n"
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(9)" + Zc.HostInfo.writableLocation(9) + "\n"*/


        console.log(">> crowdDocumentFolder.files.count " + crowdDocumentFolder.files.count)

    }

    onClosed : {
        activity.stop();
    }
}
