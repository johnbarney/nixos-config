// Original implementation inspired by Omarchy's menu/workspaces | clock |
// tray/network/audio/power bar composition.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland

PanelWindow {
  id: bar

  required property var shellRoot
  readonly property color backgroundColor: "#1e1e2e"
  readonly property color foregroundColor: "#cdd6f4"
  readonly property color accentColor: "#89b4fa"
  readonly property color mutedColor: "#585b70"
  readonly property var sink: Pipewire.defaultAudioSink

  function workspaceById(workspaceId) {
    var workspaces = Hyprland.workspaces.values
    for (var i = 0; i < workspaces.length; i++) {
      if (workspaces[i].id === workspaceId) return workspaces[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var workspaces = Hyprland.workspaces.values
    for (var i = 0; i < workspaces.length; i++) {
      var workspaceId = workspaces[i].id
      if (workspaceId > 0 && workspaceId <= 10 && ids.indexOf(workspaceId) === -1)
        ids.push(workspaceId)
    }
    return ids.sort(function(left, right) { return left - right })
  }

  function connectionLabel() {
    var devices = Networking.devices ? Networking.devices.values : []
    for (var i = 0; i < devices.length; i++) {
      if (!devices[i].connected) continue
      if (devices[i].type === DeviceType.Wifi) return "Wi-Fi"
      if (devices[i].type === DeviceType.Wired) return "Wired"
      return "Online"
    }
    return "Offline"
  }

  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: 36
  color: backgroundColor
  WlrLayershell.namespace: "nixos-omarchy-bar"
  WlrLayershell.layer: WlrLayer.Top

  PwObjectTracker {
    objects: bar.sink ? [bar.sink] : []
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    spacing: 8

    Rectangle {
      implicitWidth: 30
      implicitHeight: 26
      radius: 4
      color: menuMouse.containsMouse ? bar.mutedColor : "transparent"

      Text {
        anchors.centerIn: parent
        text: "≡"
        color: bar.foregroundColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
      }

      MouseArea {
        id: menuMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: bar.shellRoot.toggleLauncher()
      }
    }

    Repeater {
      model: bar.workspaceIds()

      delegate: Rectangle {
        id: workspaceButton
        required property int modelData
        readonly property var workspace: bar.workspaceById(modelData)
        readonly property bool focused: Hyprland.focusedWorkspace !== null
          && Hyprland.focusedWorkspace.id === modelData
        readonly property bool occupied: workspace !== null
          && workspace.toplevels.values.length > 0

        implicitWidth: 25
        implicitHeight: 25
        radius: 4
        color: focused ? bar.accentColor : (workspaceMouse.containsMouse ? bar.mutedColor : "transparent")
        opacity: occupied || focused ? 1 : 0.55

        Text {
          anchors.centerIn: parent
          text: workspaceButton.modelData === 10 ? "0" : String(workspaceButton.modelData)
          color: workspaceButton.focused ? "#101019" : bar.foregroundColor
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 12
          font.bold: workspaceButton.focused
        }

        MouseArea {
          id: workspaceMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: Hyprland.dispatch("workspace " + workspaceButton.modelData)
        }
      }
    }

    Item { Layout.fillWidth: true }

    Text {
      text: Qt.formatDateTime(clock.date, "dddd HH:mm")
      color: bar.foregroundColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
      font.bold: true
    }

    Item { Layout.fillWidth: true }

    Repeater {
      model: SystemTray.items

      delegate: Item {
        id: trayButton
        required property var modelData
        implicitWidth: 24
        implicitHeight: 24

        Image {
          anchors.centerIn: parent
          width: 16
          height: 16
          source: trayButton.modelData.icon
          fillMode: Image.PreserveAspectFit
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) trayButton.modelData.secondaryActivate()
            else trayButton.modelData.activate()
          }
        }
      }
    }

    Text {
      text: bar.connectionLabel()
      color: bar.connectionLabel() === "Offline" ? "#f38ba8" : bar.foregroundColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 11
    }

    Rectangle {
      implicitWidth: audioLabel.implicitWidth + 12
      implicitHeight: 25
      radius: 4
      color: audioMouse.containsMouse ? bar.mutedColor : "transparent"

      Text {
        id: audioLabel
        anchors.centerIn: parent
        text: {
          if (!bar.sink || !bar.sink.audio) return "Audio"
          if (bar.sink.audio.muted) return "Muted"
          return Math.round(bar.sink.audio.volume * 100) + "%"
        }
        color: bar.foregroundColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
      }

      MouseArea {
        id: audioMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          if (bar.sink && bar.sink.audio)
            bar.sink.audio.muted = !bar.sink.audio.muted
        }
        onWheel: function(wheel) {
          if (!bar.sink || !bar.sink.audio) return
          var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
          bar.sink.audio.volume = Math.max(0, Math.min(1, bar.sink.audio.volume + delta))
        }
      }
    }

    Text {
      visible: UPower.displayDevice !== null && UPower.displayDevice.isPresent
      text: visible ? Math.round(UPower.displayDevice.percentage * 100) + "%" : ""
      color: UPower.onBattery && UPower.displayDevice.percentage < 0.15
        ? "#f38ba8"
        : bar.foregroundColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 11
    }
  }
}
