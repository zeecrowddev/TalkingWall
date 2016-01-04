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

import ZcClient 1.0 as Zc
import "../Components" as TwComponents
import QtMultimedia 5.4

Item{
    id : twDelegate
    width: GridView.view.cellWidth - 2
    height: GridView.view.cellHeight - 2

    Rectangle {
        anchors.fill: parent
        color : "lightgrey"
    }

    Column {
        anchors.fill: parent

        Image {
            id: imageId
            source: crowdDocumentFolder.getUrlFromFileName(name)

            fillMode: Image.PreserveAspectFit

            height: width
            width : parent.width

            onStatusChanged: {
                console.log("status: " + status);
                if (status !== Image.Error ) {
                    messageTextId.visible = false;
                    messageTextId.text = "";
                }
                else {
                    messageTextId.visible = false;
                    messageTextId.text = "Error";
                }
            }

            onProgressChanged: {
                if ( status === Image.Loading) {
                    messageTextId.text = Math.round(imageId.progress * 100) + "%";
                    messageTextId.visible = true;
                }
            }

            Text {
                id : messageTextId
                anchors.centerIn : parent
                color : "black"
                text : qsTr("Loading...")
            }

            MouseArea {
                anchors.fill: parent

                onPressAndHold: {
                    contextualMenu.fileDescriptor = item;
                    contextualMenu.show();
                }

                onClicked: {
                    mainView.playSound(item);
                }
            }
        }

        Text {
            id : text
            width : parent.width
            height : width * 1/8

            color : "black"
            text: mainView.getName(name)
            clip : true
            elide : Text.ElideRight
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: height*0.8
        }

        Text {
            id : date
            width : parent.width
            height : width * 1/8

            color : "black"
            text: remoteTimeStampLabel.replace(" GMT","")
            clip : true
            elide : Text.ElideRight
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: height*0.5
        }
    }
}
