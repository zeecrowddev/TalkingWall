import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtMultimedia 5.5
import "../Components" as PiComponents

import ZcClient 1.0 as Zc

import "../"

Item {

    id : cameraView

    property bool readyToSave : false
    anchors.fill: parent
    property string path : ""
    property string audioTmpFileName : ""

    signal validated();

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
                text: qsTr("Flip Camera")
                onClicked: {
                    cameraView.flipCamera();
                }
            }
        }
    }



    Component.onCompleted: {
        camera.stop()

        if (Qt.platform.os  == "ios") {
            audioTmpFileName = Zc.HostInfo.writableLocation(7) + "/audio.wav";
        } else if (Qt.platform.os  == "android") {
            audioTmpFileName = Zc.HostInfo.writableLocation(4) + "/audio";
        } else {
            audioTmpFileName = Zc.HostInfo.writableLocation(7) + "/audio.wav";
        }
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
    }

    function record() {

        audioRecorder.outputFileLocation = audioTmpFileName
        progressBarId.visible = true;
        timerId.running = true;
        audioRecorder.record();
    }

    Zc.Image
    {
        id : imageId
    }

    Zc.AudioRecorder {

        id : audioRecorder
    }

    Timer {
        id : timerId
           property int cpt : 0
           interval: 500; running: false; repeat: false
           onTriggered: {
               cpt ++;
               if (cpt === 12) {
                   running = false;
                   validated();
               }
               progressBarId.value = cpt;

           }


    }

    Rectangle
    {
        anchors.fill: parent
        color : "white"
    }

    Item
    {
        id : cameraViewer
        anchors.fill: parent

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
                    //resourceViewer.nextButtonText = "Validate >"

                    cameraView.path = camera.imageCapture.capturedImagePath ////mainView.context.temporaryPath + "cameraCapture.jpg";
                    var imageSource = path;
                    if (Qt.platform.os === "windows" && cameraView.path.search("file:///") === -1)
                    {
                        imageSource = "file:///" + path
                    }
                    else if (Qt.platform.os === "ios")
                    {
                        imageSource = "file:/" + path
                    }
                    else if (Qt.platform.os === "android")
                    {
                        imageSource = "file://" + path
                    }
                    else {
                        imageSource = "path"
                    }

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
                }

            }
        }

        VideoOutput {
            id : videoOutput
            source: camera

            width : parent.width > parent.height ? parent.width : parent.height
            height : parent.height > parent.width ? parent.height : parent.width

            focus : visible // to receive focus and capture key events when visible

            autoOrientation : true

            MouseArea
            {
                anchors.fill: parent

                onClicked: {
                    //resourceViewer.nextButtonText = "Validate >"

                    var tmpFileName = mainView.context.temporaryPath + "cameraCapture.jpg";
                    camera.imageCapture.capture();
                }
            }
        }
    }

    Image
    {
        id: photoPreview
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        visible: false;
        fillMode: Image.PreserveAspectFit
        cache: false
        autoTransform : true

        Button {
            anchors.centerIn: parent
            text: qsTr("Record")
            onClicked: {
                record()
            }
        }
    }


    ProgressBar {
        id : progressBarId
        anchors.verticalCenter: parent
        width : parent.width
        minimumValue: 0
        maximumValue: 12
        visible : false
    }
}
