import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtMultimedia 5.5
import "../Components" as TwComponents

import ZcClient 1.0 as Zc

import "../"

Item {

    id : cameraView

    property bool readyToSave : false
    anchors.fill: parent

    property string photoTmpFileName : ""
    property string audioTmpFileName : ""

    signal validated();
    signal canceled();


    // selon le device le repertoire temporarire et nom (extensio ndu fichier change)
    function generateTemporaryAudioFileName() {
        if (Qt.platform.os  == "ios") {
            return Zc.HostInfo.writableLocation(7) + "/audio.wav";
        } else if (Qt.platform.os  == "android") {
            return Zc.HostInfo.writableLocation(4) + "/audio";
        } else {
            return Zc.HostInfo.writableLocation(7) + "/audio.wav";
        }
    }

    Component.onCompleted: {
        camera.stop()
        audioTmpFileName = generateTemporaryAudioFileName();
    }

    Component.onDestruction: {
        camera.stop()
    }

    function open() {
        visible = true
        camera.start();
    }

    function close() {
        visible = false
        camera.stop()
    }

    function flipCamera() {
        if (camera.position === Camera.BackFace) {
            camera.position = Camera.FrontFace;
        } else {
            camera.position = Camera.BackFace;
        }
    }

    function stopRecord() {
        audioRecorder.stop();
        button1Id.visible = true
        button2Id.text = qsTr("Play")
        button3Id.visible = true
    }

    function record() {
        audioRecorder.outputFileLocation = audioTmpFileName
        progressBarId.visible = true;
        //buttonRecord.visible = false
        timerId.start();
        audioRecorder.record();
    }

    Zc.Image
    {
        id : imageId
    }

    Zc.Image
    {
        id : imageDestId
    }

    Zc.AudioRecorder {

        id : audioRecorder
    }

    Timer {
        id : timerId
           property int cpt : 0
           interval: 200; running: false; repeat: true
           onTriggered: {
               cpt = cpt + 1;
               if (cpt === progressBarId.maximumValue) {
                   stop();
                   stopRecord();
               }
               progressBarId.value = cpt;

           }
    }

    Rectangle
    {
        id : backgroundId
        anchors{
            top : parent.top
            left : parent.left
            right : parent.right
            bottom : toolbarBoard.top
        }
        color : "white"
    }

    Item
    {
        id : cameraViewer

        anchors{
            top : parent.top
            left : parent.left
            right : parent.right
            bottom : toolbarBoard.top
        }

        Camera
        {
            id: camera

            imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

            exposure {
                exposureMode: Camera.ExposureAuto
            }

            flash.mode: Camera.FlashRedEyeReduction

            imageCapture {

                onImageSaved:
                {
                    cameraViewer.visible = false
                    photoPreview.visible = true

                    var resultLoad = imageId.load(camera.imageCapture.capturedImagePath);
                    console.log("ResultLoad " + resultLoad )

                    if (imageId.width > imageId.height) {
                        var x = (imageId.width - imageId.height) /2;
                        var y = 0;
                        var width = imageId.height;
                        var height = imageId.height;
                        imageId.copyTo(imageDestId,x,y,width,height);
                    } else {

                        var y = (imageId.height - imageId.width) / 2;
                        var x = 0;
                        var width = imageId.width;
                        var height = imageId.width;
                        imageId.copyTo(imageDestId,x,y,width,height);
                    }

                    imageDestId.save(camera.imageCapture.capturedImagePath)
                    cameraView.photoTmpFileName = camera.imageCapture.capturedImagePath
                    var imageSource = cameraView.photoTmpFileName;
                    if (Qt.platform.os === "windows" && cameraView.photoTmpFileName.search("file:///") === -1)
                    {
                        imageSource = "file:///" + photoTmpFileName
                    }
                    else if (Qt.platform.os === "ios")
                    {
                        imageSource = "file:/" + photoTmpFileName
                    }
                    else if (Qt.platform.os === "android")
                    {
                        imageSource = "file://" + cameraView.photoTmpFileName
                    }
                    else {
                        imageSource = cameraView.photoTmpFileName
                    }

                    console.log(">> imageSource " + imageSource)


                    if (camera.orientation != videoOutput.orientation)
                    {
                        photoPreview.rotation = camera.orientation - videoOutput.orientation
                    }
                    else
                     {
                        photoPreview.rotation = 0
                    }

                    photoPreview.source = imageSource

                    readyToSave = true;
                    camera.stop();
                    record();
                }

            }
        }

        VideoOutput {
            id : videoOutput
            source: camera

            anchors.centerIn: parent

            width : Math.min(parent.width,parent.height)
            height : width

            focus : visible // to receive focus and capture key events when visible
            fillMode:  VideoOutput.PreserveAspectCrop

            autoOrientation : true


        }
    }

    Image
    {
        id: photoPreview
        anchors.centerIn: parent

        width : Math.min(parent.width,parent.height)
        height : width

        visible: false;
        fillMode: Image.PreserveAspectFit
        cache: false
        autoTransform : true

        /*Button {
            id : buttonRecord
            anchors.centerIn: parent
            text: qsTr("Record")
            onClicked: {
                record()
            }
        }*/
    }


    ProgressBar {
        id : progressBarId
        anchors.verticalCenter: parent.verticalCenter
        width : parent.width
        minimumValue: 0
        maximumValue: 20
        visible : false
    }

    MouseArea
    {
        id : mouseArea

        anchors {
            top : parent.top
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            bottomMargin: toolBarId.height
        }

        onPressed: {
            var tmpFileName = mainView.context.temporaryPath + "cameraCapture.jpg";
            camera.imageCapture.capture();
        }

        onReleased: {
            progressBarId.visible = false
            timerId.stop();
            stopRecord();
            mouseArea.enabled = false;
        }
    }

    Audio {
        id: playMusic
    }

    TwComponents.ToolBar
    {
        id : toolbarBoard

        anchors {
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            topMargin : 1
        }

        RowLayout {
            id : toolBarId
            anchors.fill: parent

            TwComponents.ToolButton {
                id : button1Id
                visible : false
                text: qsTr("Back")
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    cameraView.canceled();
                }
            }
            TwComponents.ToolButton {
                id : button2Id
                text: qsTr("Flip Camera")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    cameraView.flipCamera()

                    if (Qt.platform.os  == "ios") {
                        playMusic.source = "file:/" + audioTmpFileName
                    } else if (Qt.platform.os  == "android") {
                        playMusic.source = "file://" + audioTmpFileName
                    } else {
                        playMusic.source = audioTmpFileName
                    }

                    playMusic.play()
                }
            }
            TwComponents.ToolButton {
                id : button3Id
                visible : false
                text: qsTr("Send")
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    cameraView.validated();
                }
            }
        }
    }

}
