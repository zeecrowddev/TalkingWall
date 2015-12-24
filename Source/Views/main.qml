/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the ZcPostIt application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* TalkingWal is free software: you can redistribute it and/or modify
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
import "../Components" as TwComponents
import QtMultimedia 5.4

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    property string audioTmpFileName : ""

    property var currentFileDescriptor : null

    property string _extensionSound : ".wav"
    property string _extensionImage : ".jpg"


    function getName(n)
    {
        return n.substring(0,n.lastIndexOf("_"))
    }

    function getNumber(n)
    {
        return parseInt(n.substring(n.lastIndexOf("_")+1,n.length-1))
    }


    TwComponents.ActionList {
        id: contextualMenu

        property var fileDescriptor : null

        Action {
            text: qsTr("Delete")
            onTriggered: {

                if (getName(contextualMenu.fileDescriptor.name) === mainView.context.nickname) {
                    console.log(">> contextualMenu.fileDescriptor " + contextualMenu.fileDescriptor)
                    crowdDocumentFolder.deleteFile(contextualMenu.fileDescriptor)
                }
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
                mainView.close();
            }
        }
        /*
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
        }*/
        ,
        Action {
            id: addNew
            text:  "Add"
            onTriggered: {
                mainToolBar.visible = false
                cameraLoader.visible = true
                cameraLoader.sourceComponent = cameraViewComponent
                cameraLoader.item.open()
            }
        }
    ]


    function playSound(fileDescriptor) {
        busyIndicator.title = "Playing"
        busyIndicator.running = true

        var name = fileDescriptor.name;
        console.log(">> name " + name)
        var nameWav = fileDescriptor.name.replace(_extensionImage,_extensionSound);
        console.log(">> nameWav " + nameWav)
        var url = crowdDocumentFolder.getUrlFromFileName(name);
        console.log(">> url " + url)
        url = url.replace(name,"sounds/" + nameWav);
        console.log(">> url to play " + url)

        var to = "";

        if (Qt.platform.os  == "ios") {
            to = Zc.HostInfo.writableLocation(7) + "/listen.wav";
        } else if (Qt.platform.os  == "android") {
            to  =  Zc.HostInfo.writableLocation(4) + "/listen.wav";
        } else {
            to = Zc.HostInfo.writableLocation(7) + "/listen.wav";
        }

        playMusicLoader.sourceComponent = undefined

        crowdDocumentFolder.localPath = "";
        var result = crowdDocumentFolder.removeLocalFile(to);

        console.log(">> delete file " + to)
        console.log(">> result delete file " + result)


        result = crowdSharedResource.downloadFileTo("sounds/" + nameWav,to,downloadFileQueryId);

        console.log(">> result " + result)


    }

    Zc.SortFilterObjectListModel
    {
        id : sortFilterObjectListModel
    }

    Zc.JavaScriptSorter
    {
        id : javaScriptSorter

        function lessThan(left,right)
        {
            return getNumber(left.name) > getNumber(right.name);
        }
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


    Component {

        id : playMusicComponent

        Audio {
            id: playMusic
            onStopped: {
                playMusicLoader.sourceComponent = undefined
                busyIndicator.running = false
            }
        }
    }

    Loader {
        id : playMusicLoader
        anchors.fill: parent
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

                    playMusicLoader.sourceComponent = playMusicComponent

                    if (Qt.platform.os  == "ios") {
                        playMusicLoader.item.source = "file:/" + to
                    } else if (Qt.platform.os  == "android") {
                        playMusicLoader.item.source = "file://" + to
                    } else {
                        playMusicLoader.item.source = to
                    }

                    playMusicLoader.item.source = to
                    console.log(">> playMusic.source " + playMusicLoader.item.source)

                    playMusicLoader.item.play()


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
                    busyIndicator.running = false
                }

                onCompleted :
                {
                    busyIndicator.running = false
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

                // on ne prend pas en compte les les fichiers son dans la notification
                if (fileName.indexOf(_extensionSound) !== -1)
                    return;

                if (fileName.indexOf(_extensionSound) === -1) {
                    appNotification.logEvent(Zc.AppNotification.Add,"File",fileName,"image://icons/" + "file:///" + fileName)
                    notifySender.sendMessage("","{ \"action\" : \"added\" , \"fileName\" : \"" + fileName + "\" , \"lastModified\" : \"" + currentFileDescriptor.timeStamp + "\" }");
                }
            }

            onFileDeleted : {
                notifySender.sendMessage("","{ \"action\" : \"deleted\" , \"fileName\" : \"" + fileName + "\" } ");
            }

        }

        onStarted :
        {

            sortFilterObjectListModel.setModel(crowdDocumentFolder.files);
            javaScriptSorter.qmlObjectSorter = javaScriptSorter;
            sortFilterObjectListModel.setSorter(javaScriptSorter);

            grid.model = sortFilterObjectListModel
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
        delegate:
            TWDelegate{

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

            onCanceled : {
                cameraLoader.item.close()
                cameraLoader.sourceComponent = undefined
                cameraLoader.visible = false
                mainToolBar.visible = true
            }

            onValidated : {

                console.log(">>> A que coucou")

                var fdSound = crowdDocumentFolder.createFileDescriptorFromFile(cameraLoader.item.audioTmpFileName);
                var fdImage = crowdDocumentFolder.createFileDescriptorFromFile(cameraLoader.item.photoTmpFileName);

                var d = new Date();
                var fileNameId = mainView.context.nickname + "_" + d.getTime();

                if (fdSound !== null)
                {
                    // ATTENTION REVOIRE CELA POUR LES DEVICE
                    fdSound.name = "sounds/"+ fileNameId + mainView._extensionSound
                    console.log(">> fdSound.name " + fdSound.name)
                    crowdDocumentFolder.localPath = "";
                    currentFileDescriptor = fdSound;
                    var result = crowdDocumentFolder.uploadFile(fdSound,cameraLoader.item.audioTmpFileName)
                    console.log(">> result : " + result)
                }

                console.log(">> cameraLoader.item.path "  + cameraLoader.item.photoTmpFileName)
                console.log(">> fdImage.name before " + fdImage.name)

                if (fdImage !== null)
                {
                    fdImage.name = fileNameId + _extensionImage

                    console.log(">> fdImage.name after " + fdImage.name)
                    crowdDocumentFolder.localPath = "";
                    currentFileDescriptor = fdImage;
                    result = crowdDocumentFolder.uploadFile(fdImage,cameraLoader.item.photoTmpFileName)
                    console.log(">> result : " + result)
                }


                cameraLoader.item.close()
                cameraLoader.sourceComponent = undefined
                cameraLoader.visible = false
                mainToolBar.visible = true
            }
        }
    }


    TwComponents.ToolBar
    {

        id : mainToolBar

        anchors {
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            topMargin : 1
        }

        RowLayout {
            anchors.fill: parent

            TwComponents.ToolButton {
                text: qsTr("Add New")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    mainToolBar.visible = false
                    cameraLoader.visible = true
                    cameraLoader.sourceComponent = cameraViewComponent
                    cameraLoader.item.open()
                }
            }
        }
    }



    onLoaded : {
        activity.start();

        //audioTmpFileName = generateTemporaryAudioFileName();


        //console.log(">> audioTmpFileName " + audioTmpFileName)
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
        textArea.text = textArea.text + "Zc.HostInfo.writableLocation(9)" + Zc.HostInfo.writableLocation(9) + "\n"
*/

    }

    onClosed : {
        activity.stop();
    }

    TwComponents.BusyIndicator
    {
        id : busyIndicator
        running: true
        title : "Loading"

    }
}
