/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Sebastien Bacher <sebastien.bacher@canonical.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import GSettings 1.0
import QtQuick 2.4
import Ubuntu.Components 1.3
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as OldListItem
import Ubuntu.SystemSettings.Sound 1.0
import Ubuntu.Settings.Menus 0.1 as Menus
import Ubuntu.Settings.Components 0.1 as USC
import QMenuModel 0.1

import "utilities.js" as Utilities

ItemPage {
    id: root

    objectName: "soundPage"

    title: i18n.tr("Sound")
    flickable: scrollWidget

    UbuntuSoundPanel { id: backendInfo }

    GSettings {
        id: keyboardSettings

        schema.id: "com.canonical.keyboard.maliit"
    }

    GSettings {
        id: soundSettings
        schema.id: "com.ubuntu.touch.sound"
    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ?
                            Flickable.DragAndOvershootBounds :
                            Flickable.StopAtBounds
        /* Set the direction to workaround https://bugreports.qt-project.org/browse/QTBUG-31905
           otherwise the UI might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            ListItem {
                height: silentLayout.height
                SlotsLayout {
                    id: silentLayout
                    Label {
                        text: i18n.tr("Silent Mode")
                    }
                    Switch {
                        id: silentModeSwitch
                        objectName: "silentMode"
                        property bool serverChecked: soundActionGroup.silentMode.state

                        USC.ServerPropertySynchroniser {
                            userTarget: silentModeSwitch
                            userProperty: "checked"
                            serverTarget: silentModeSwitch
                            serverProperty: "serverChecked"

                            onSyncTriggered: soundActionGroup.silentMode.activate()
                        }
                    }
                }
            }

            SettingsItemTitle {
                text: i18n.tr("Ringer:")
            }

            QDBusActionGroup {
                id: soundActionGroup
                busType: DBus.SessionBus
                busName: "com.canonical.indicator.sound"
                objectPath: "/com/canonical/indicator/sound"

                property variant volume: action("volume")
                property variant silentMode: action("silent-mode")
                property variant highVolume: action("high-volume")

                Component.onCompleted: start()
            }

            Menus.SliderMenu {
                id: volumeSlider
                objectName: "sliderMenu"
                enabled: soundActionGroup.volume.state != null
                minimumValue: 0.0
                maximumValue: 1.0
                minIcon: "image://theme/audio-volume-low-zero"
                maxIcon: "image://theme/audio-volume-high"

                property real serverValue: soundActionGroup.volume.state

                USC.ServerPropertySynchroniser {
                    userTarget: volumeSlider
                    userProperty: "value"
                    serverTarget: volumeSlider
                    serverProperty: "serverValue"
                    maximumWaitBufferInterval: 16

                    onSyncTriggered: soundActionGroup.volume.updateState(value);
                }
            }

            ListItem {
                id: highVolumeWarning
                height: highVolumeLayout.height
                visible: soundActionGroup.highVolume.state == true
                SlotsLayout {
                    id: highVolumeLayout
                    Label {
                        text: i18n.tr("High volume can damage your hearing.")
                    }
                }
            }

            SettingsItemTitle {
                text: i18n.tr("Phone calls:")
            }

            ListItem {
                height: ringtoneLayout.height
                ListItemLayout {
                    id: ringtoneLayout
                    title.text: i18n.tr("Ringtone")
                    Label { text: Utilities.buildDisplayName(backendInfo.incomingCallSound) }
                    ProgressionSlot {}
                }

                onClicked: pageStack.push(
                    Qt.resolvedUrl("SoundsList.qml"), {
                        title: i18n.tr("Ringtone"),
                        showStopButton: true,
                        soundType: 0,
                        soundsDir: "/usr/share/sounds/ubuntu/ringtones/"
                    }
                )
            }

            OldListItem.Standard {
                control: CheckBox {
                    objectName: "callVibrate"
                    property bool serverChecked: backendInfo.incomingCallVibrate
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: backendInfo.incomingCallVibrate = checked
                }
                text: i18n.tr("Vibrate on ring")
            }

            OldListItem.Standard {
                control: CheckBox {
                    objectName: "callVibrateSilentMode"
                    property bool serverChecked: backendInfo.incomingCallVibrateSilentMode
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: backendInfo.incomingCallVibrateSilentMode = checked
                }
                text: i18n.tr("Vibrate in Silent Mode")
            }

            OldListItem.Standard {
                control: Switch {
                    objectName: "dialpadSounds"
                    property bool serverChecked: backendInfo.dialpadSoundsEnabled
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: backendInfo.dialpadSoundsEnabled = checked
                }
                text: i18n.tr("Dialpad tones")
            }

            SettingsItemTitle {
                text: i18n.tr("Messages:")
            }

            OldListItem.SingleValue {
                text: i18n.tr("Message received")
                value:Utilities.buildDisplayName(
                          backendInfo.incomingMessageSound)
                progression: true
                onClicked: pageStack.push(
                               Qt.resolvedUrl("SoundsList.qml"),
                               { title: i18n.tr("Message received"),
                                  soundType: 1,
                                 soundsDir:
                                   "/usr/share/sounds/ubuntu/notifications/" })
            }

            OldListItem.Standard {
                control: CheckBox {
                    objectName: "messageVibrate"
                    property bool serverChecked: backendInfo.incomingMessageVibrate
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: backendInfo.incomingMessageVibrate = checked
                }
                text: i18n.tr("Vibrate with message sound")
            }

            OldListItem.Standard {
                control: CheckBox {
                    objectName: "messageVibrateSilentMode"
                    property bool serverChecked: backendInfo.incomingMessageVibrateSilentMode
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: backendInfo.incomingMessageVibrateSilentMode = checked
                }
                text: i18n.tr("Vibrate in Silent Mode")
            }

            SettingsItemTitle {
                text: i18n.tr("Other sounds:")
            }

            OldListItem.Standard {
                text: i18n.tr("Keyboard sound")

                control: Switch {
                    objectName: "keyboardSoundSwitch"
                    property bool serverChecked: keyboardSettings.keyPressFeedback
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: keyboardSettings.keyPressFeedback = checked
                }
            }

            OldListItem.Standard {
                id: lockSound
                control: Switch {
                    checked: false
                }
                text: i18n.tr("Lock sound")
                visible: showAllUI
            }

            OldListItem.Divider {}

            OldListItem.Standard {
                text: i18n.tr("Other vibrations")
                control: Switch {
                    objectName: "otherVibrateSwitch"
                    property bool serverChecked: backendInfo.otherVibrate
                    onServerCheckedChanged: checked = serverChecked
                    Component.onCompleted: checked = serverChecked
                    onTriggered: backendInfo.otherVibrate = checked
                }
            }
        }
    }
}
