/*
 * Copyright (C) 2015 Aditya Mehra <aix.m@outlook.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) version 3, or any
 * later version accepted by the membership of KDE e.V. (or its
 * successor approved by the membership of KDE e.V.), which shall
 * act as a proxy defined in Section 6 of version 3 of the license.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Controls 2.1
import Qt.WebSockets 1.0

import org.kde.kio 1.0 as Kio
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.1 as Kirigami

Rectangle {
    id: mycroftaccess
    width: units.gridUnit * 2
    color: "transparent"
    Layout.alignment: Qt.AlignTop

    function playwaitanim(recoginit){
       switch(recoginit){ //"mycroft.skill.handler.start":
       case "recognizer_loop:record_begin":
               drawer.open()
               waitanimoutter.cstanim.visible = true
               waitanimoutter.cstanim.running = true
               break
        case "recognizer_loop:record_end":
               kRun.openUrl("/usr/share/applications/org.mycroft.kirigami.desktop");
               break
        case "recognizer_loop:audio_output_start":
               drawer.close()
               waitanimoutter.cstanim.visible = false
               waitanimoutter.cstanim.running = false
               break
        case "mycroft.skill.handler.complete":
               drawer.close()
               waitanimoutter.cstanim.running = false
               break
       }
   }

   Kio.KRun {
        id: kRun
    }
    
    WebSocket {
        id: socket
        url: "ws://0.0.0.0:8181/core"
        onTextMessageReceived: {
            var somestring = JSON.parse(message)
            var msgType = somestring.type;
            playwaitanim(msgType);
            }
            
        active: true
    }
    
    PlasmaComponents.ToolButton {
        id: micBttn
        width: units.gridUnit * 2
        height: units.gridUnit * 2
        iconSource: "audio-input-microphone"
        
        onClicked: {
            var socketmessage = {};
            socketmessage.type = "mycroft.mic.listen";
            socketmessage.data = {};
            socketmessage.data.utterances = [];
            socket.sendTextMessage(JSON.stringify(socketmessage));
        }
    }
        
    Drawer {
        id: drawer
        width: parent.width
        height: units.gridUnit * 5.5
        y:  micBttn.height + units.gridUnit * 4
        
            CustomBusyIndicator {
              id: waitanimoutter
              height: 70
              width: 70
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
             }
          }
        }
