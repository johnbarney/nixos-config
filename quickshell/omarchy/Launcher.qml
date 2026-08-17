// Original, deliberately small application launcher for the NixOS Omarchy
// flavor. Desktop entry discovery and execution are provided by Quickshell.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: launcher

  required property var shellRoot
  readonly property color backgroundColor: "#1e1e2e"
  readonly property color darkerBackgroundColor: "#101019"
  readonly property color lighterBackgroundColor: "#313244"
  readonly property color foregroundColor: "#cdd6f4"
  readonly property color mutedColor: "#585b70"
  readonly property color accentColor: "#89b4fa"

  function filteredApplications() {
    var query = search.text.trim().toLowerCase()
    var entries = DesktopEntries.applications.values || []
    var matches = []

    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      var name = String(entry.name || "")
      var genericName = String(entry.genericName || "")
      if (query !== ""
          && name.toLowerCase().indexOf(query) === -1
          && genericName.toLowerCase().indexOf(query) === -1)
        continue
      matches.push(entry)
    }

    matches.sort(function(left, right) {
      return String(left.name || "").localeCompare(String(right.name || ""))
    })
    return matches.slice(0, 9)
  }

  function launchSelected() {
    if (applications.currentIndex < 0 || applications.currentIndex >= applicationModel.values.length)
      return
    applicationModel.values[applications.currentIndex].execute()
    shellRoot.closeLauncher()
  }

  visible: shellRoot.launcherOpen && shellRoot.launcherScreenName === screen.name
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  color: "#99000000"
  exclusiveZone: 0
  WlrLayershell.namespace: "nixos-omarchy-launcher"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  onVisibleChanged: {
    if (visible) {
      search.text = ""
      applications.currentIndex = 0
      search.forceActiveFocus()
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: launcher.shellRoot.closeLauncher()
  }

  Rectangle {
    id: card
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 72
    width: Math.min(620, parent.width - 40)
    height: Math.min(510, parent.height - 112)
    radius: 8
    color: launcher.backgroundColor
    border.width: 2
    border.color: launcher.accentColor

    MouseArea {
      anchors.fill: parent
      onClicked: function(mouse) { mouse.accepted = true }
    }

    TextInput {
      id: search
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 18
      height: 44
      leftPadding: 14
      rightPadding: 14
      color: launcher.foregroundColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 15
      verticalAlignment: TextInput.AlignVCenter
      selectByMouse: true
      clip: true

      Rectangle {
        anchors.fill: parent
        z: -1
        radius: 5
        color: launcher.darkerBackgroundColor
        border.width: 1
        border.color: search.activeFocus ? launcher.accentColor : launcher.mutedColor
      }

      Text {
        anchors.fill: parent
        leftPadding: search.leftPadding
        verticalAlignment: Text.AlignVCenter
        text: "Search applications…"
        color: launcher.mutedColor
        font: search.font
        visible: search.text.length === 0
      }

      Keys.onEscapePressed: launcher.shellRoot.closeLauncher()
      Keys.onDownPressed: applications.currentIndex = Math.min(
        applications.count - 1,
        applications.currentIndex + 1
      )
      Keys.onUpPressed: applications.currentIndex = Math.max(0, applications.currentIndex - 1)
      Keys.onReturnPressed: launcher.launchSelected()
      Keys.onEnterPressed: launcher.launchSelected()
    }

    ScriptModel {
      id: applicationModel
      values: launcher.filteredApplications()
    }

    ListView {
      id: applications
      anchors.top: search.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: hint.top
      anchors.topMargin: 14
      anchors.leftMargin: 18
      anchors.rightMargin: 18
      anchors.bottomMargin: 10
      spacing: 4
      clip: true
      model: applicationModel
      currentIndex: count > 0 ? 0 : -1

      delegate: Rectangle {
        id: applicationRow
        required property var modelData
        required property int index
        property var entry: modelData

        function launch() {
          applicationRow.entry.execute()
          launcher.shellRoot.closeLauncher()
        }

        width: applications.width
        height: 43
        radius: 5
        color: ListView.isCurrentItem || rowMouse.containsMouse
          ? launcher.lighterBackgroundColor
          : "transparent"

        Image {
          id: applicationIcon
          anchors.left: parent.left
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          width: 24
          height: 24
          source: Quickshell.iconPath(applicationRow.entry.icon, true)
          fillMode: Image.PreserveAspectFit
        }

        Text {
          anchors.left: applicationIcon.right
          anchors.right: parent.right
          anchors.leftMargin: 12
          anchors.rightMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          text: applicationRow.entry.name
          color: launcher.foregroundColor
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 13
          elide: Text.ElideRight
        }

        MouseArea {
          id: rowMouse
          anchors.fill: parent
          hoverEnabled: true
          onEntered: applications.currentIndex = applicationRow.index
          onClicked: applicationRow.launch()
        }
      }
    }

    Text {
      id: hint
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 14
      horizontalAlignment: Text.AlignHCenter
      text: "↑/↓ select  ·  Enter launch  ·  Esc close"
      color: launcher.mutedColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 10
    }
  }
}
