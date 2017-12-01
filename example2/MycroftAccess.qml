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
    property var smintent
    property var dataContent
    property alias cbwidth: drawer.width
    
    function toggleInputMethod(selection){
        switch(selection){
        case "KeyboardSetActive":
            qinput.visible = true
            customMicIndicator.visible = false
            keybindic.color = "green"
            break
        case "KeyboardSetDisable":
            qinput.visible = false
            customMicIndicator.visible = true
            keybindic.color = theme.textColor
            break
        }
   }
    
     function filterSpeak(msg){
        convoLmodel.append({
            "itemType": "NonVisual",
            "InputQuery": msg
        })
           inputlistView.positionViewAtEnd();
    }
    
    function playwaitanim(recoginit){
       switch(recoginit){ //"mycroft.skill.handler.start":
       case "recognizer_loop:record_begin":
               drawer.open()
               animdrawer.open()
               waitanimoutter.cstanim.visible = true
               waitanimoutter.cstanim.running = true
               break
        case "recognizer_loop:record_end":
               //kRun.openUrl("/usr/share/applications/org.mycroft.kirigami.desktop");
               //mainDraw.open()
               break
        case "recognizer_loop:audio_output_start":
               animdrawer.close()
               waitanimoutter.cstanim.visible = false
               waitanimoutter.cstanim.running = false
               break
        case "mycroft.skill.handler.complete":
               animdrawer.close()
               waitanimoutter.cstanim.running = false
               break
       }
   }

   Kio.KRun {
        id: kRun
    }
    
    ListModel{
        id: convoLmodel
        }

    WebSocket {
        id: socket
        url: "ws://0.0.0.0:8181/core"
        onTextMessageReceived: {
            var somestring = JSON.parse(message)
            var msgType = somestring.type;
            playwaitanim(msgType);
            
            if (msgType === "recognizer_loop:utterance") {
                var intpost = somestring.data.utterances;
                qinput.text = intpost.toString()
                convoLmodel.append({"itemType": "AskType", "InputQuery": intpost.toString()})
            }
            
            if (somestring && somestring.data && typeof somestring.data.intent_type !== 'undefined'){
                smintent = somestring.data.intent_type;
                console.log('intent type: ' + smintent);
            }
            
            if(somestring && somestring.data && typeof somestring.data.utterance !== 'undefined' && somestring.type === 'speak'){
                filterSpeak(somestring.data.utterance);
            }

            if(somestring && somestring.data && typeof somestring.data.desktop !== 'undefined' && somestring.type === "data") {
                dataContent = somestring.data.desktop
                filterincoming(smintent, dataContent)
            }
            
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
        height: parent.height / 2
        y:  micBttn.height + units.gridUnit * 4
        
        Kirigami.ScrollablePage {
            id: mainPage
            anchors.fill: parent
            
         ListView {
                    id: inputlistView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchors.margins: units.gridUnit * 1
                    verticalLayoutDirection: ListView.TopToBottom
                    spacing: 12
                    clip: true
                    model: convoLmodel
                    ScrollBar.vertical: ScrollBar {}
                    delegate:  Component {
                            Loader {
                                source: switch(itemType) {
                                        case "NonVisual": return "SimpleMessageType.qml"
                                        case "WebViewType": return "WebViewType.qml"
                                        case "CurrentWeather": return "CurrentWeatherType.qml"
                                        case "DropImg" : return "ImgRecogType.qml"
                                        case "AskType" : return "AskMessageType.qml"
                                        case "LoaderType" : return "LoaderType.qml"
                                        }
                                    property var metacontent : dataContent
                            }
                        }

                onCountChanged: {
                    inputlistView.positionViewAtEnd();
                                }
                }

        
footer: 

Rectangle{
                id: bottombar
                anchors.left: parent.left
                anchors.right: parent.right
                height:60
                color: Kirigami.Theme.backgroundColor
                
       Drawer {
         id: animdrawer
          width: parent.width
          height: units.gridUnit * 8
          y: bottombar.y + units.gridUnit * 1
 
          Rectangle {
            color: theme.backgroundColor
            anchors.fill: parent
            
            CustomBusyIndicator {
              id: waitanimoutter
              height: 70
              width: 70
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
             }
          }
        }
        
       Rectangle {
        id: keyboardactivaterect
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.lighter(theme.backgroundColor, 1.2)
        width: Kirigami.Units.gridUnit * 2
        height: qinput.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        PlasmaComponents.ToolButton {
            id: keybdImg
            iconSource: "input-keyboard"
            anchors.centerIn: parent
            width: Kirigami.Units.gridUnit * 2
            height: Kirigami.Units.gridUnit * 2
        }

        Rectangle {
            id: keybindic
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            height: 2
            color: theme.textColor
        }

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {}
            onExited: {}
            onClicked: {
                if(qinput.visible === false){
                    toggleInputMethod("KeyboardSetActive")
                    }
                else if(qinput.visible === true){
                    toggleInputMethod("KeyboardSetDisable")
                    }
                }
            }
        }

    PlasmaComponents.TextField {
        id: qinput
        anchors.left: keyboardactivaterect.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        visible: false
        placeholderText: i18n("Enter Query or Say 'Hey Mycroft'")
        clearButtonShown: true
        
        onAccepted: {
            var socketmessage = {};
            socketmessage.type = "recognizer_loop:utterance";
            socketmessage.data = {};
            socketmessage.data.utterances = [qinput.text];
            socket.sendTextMessage(JSON.stringify(socketmessage));
            qinput.text = ""; 
                    }
                }
                
            CustomMicIndicator {
                    id: customMicIndicator
                    anchors.centerIn: parent
                }
            }
        }
        
        onClosed: {
            convoLmodel.clear()
        }
        
    }
}

