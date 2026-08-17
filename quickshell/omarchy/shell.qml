// Original Quickshell implementation for this repository. Its single-process
// architecture and composition are inspired by Basecamp's MIT-licensed
// Omarchy project; no Omarchy QML is copied here.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
  id: shell

  property bool launcherOpen: false
  property string launcherScreenName: ""

  function focusedScreenName() {
    if (Hyprland.focusedMonitor !== null)
      return Hyprland.focusedMonitor.name
    return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : ""
  }

  function openLauncher() {
    launcherScreenName = focusedScreenName()
    launcherOpen = true
  }

  function closeLauncher() {
    launcherOpen = false
  }

  function toggleLauncher() {
    if (launcherOpen) closeLauncher()
    else openLauncher()
  }

  IpcHandler {
    target: "omarchy"

    function openLauncher(): void { shell.openLauncher() }
    function closeLauncher(): void { shell.closeLauncher() }
    function toggleLauncher(): void { shell.toggleLauncher() }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      Bar {
        required property var modelData
        screen: modelData
        shellRoot: shell
      }
    }
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      Launcher {
        required property var modelData
        screen: modelData
        shellRoot: shell
      }
    }
  }
}
