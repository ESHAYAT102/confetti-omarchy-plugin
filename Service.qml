import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"
  readonly property string launcher: configHome + "/omarchy/plugins/esh.confetti/bin/confetti-go"
  property int pendingBursts: 0

  function dispatch() {
    if (pendingBursts === 0 || fireProcess.running) return
    pendingBursts -= 1
    fireProcess.running = true
  }

  Process {
    id: daemonProcess
    command: [root.launcher, "daemon"]
  }

  Process {
    id: fireProcess
    command: [root.launcher, "fire"]
    onExited: root.dispatch()
  }

  Component.onCompleted: daemonProcess.running = true

  IpcHandler {
    target: "esh.confetti"

    function fire(): string {
      root.pendingBursts += 1
      root.dispatch()
      return "ok"
    }

    function state(): string {
      return root.pendingBursts > 0 || fireProcess.running ? "pending" : "ready"
    }
  }
}
