/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 * Ken VanDine <ken.vandine@canonical.com>
 *
*/

import QtQuick 2.4
import SystemSettings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

ItemPage {
    id: preview
    anchors.fill: parent

    property string uri

    // whether an image was just imported from e.g. contentHub
    property bool imported: false

    states: [
        State {
            name: "saved"
            StateChangeScript {
                script: {
                    save();
                    pageStack.removePages(preview);
                }
            }
        },
        State {
            name: "cancelled"
            StateChangeScript {
                script: {
                    pageStack.removePages(preview);
                }
            }
        }
    ]

    title: i18n.tr("Preview")

    Image {
        id: previewImage
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: divider.top
        }
        source: uri
        sourceSize.height: height
        sourceSize.width: 0
        fillMode: Image.PreserveAspectCrop
    }

    ListItem.ThinDivider {
        id: divider
        anchors.bottom: previewButtons.top
        anchors.bottomMargin: units.gu(2)
    }

    ListItem.Base {
        id: previewButtons
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        showDivider: false

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(2)

            Button {
                objectName: "cancelButton"
                text: preview.imported ?
                    i18n.tr("Remove image") : i18n.tr("Cancel")
                width: (previewButtons.width-units.gu(2)*4)/2
                onClicked: preview.state = "cancelled"
            }
            Button {
                objectName: "saveButton"
                text: i18n.tr("Set")
                width: (previewButtons.width-units.gu(2)*4)/2
                onClicked: preview.state = "saved"
            }
        }
    }

    /* Make the header slightly darker to ease readability on light backgrounds */
    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        color: "black"
        opacity: 0.3
        height: preview.header.height
    }
}
