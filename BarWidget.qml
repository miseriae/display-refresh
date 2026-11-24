import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Display Refresh: quick 60/120 Hz switch for an external display.
//
// Settings (shell.json entry or manifest defaults):
//   output        Hyprland output name (default HDMI-A-1)
//   highRate      high refresh rate (default 120)
//   lowRate       low refresh rate (default 60)
//   pollInterval  seconds between monitor-state reads (default 2)
//   showIcon      show the display glyph before the rate (default true)
BarWidget {
  id: root
  moduleName: "miseriae.display-refresh"

  readonly property string outputName: String(setting("output", "HDMI-A-1"))
  readonly property string prefix: String(setting("label", "EXT"))
  readonly property int highRate: Math.max(30, parseInt(setting("highRate", 120), 10) || 120)
  readonly property int lowRate: Math.max(30, parseInt(setting("lowRate", 60), 10) || 60)
  readonly property int pollInterval: Math.max(1, parseInt(setting("pollInterval", 2), 10) || 2)
  readonly property bool showIcon: boolSetting("showIcon", true)

  property var monitor: null
  property bool available: false
  property real currentRate: 0

  readonly property bool isHigh: currentRate >= highRate - 1
  readonly property int targetRate: isHigh ? lowRate : highRate
  readonly property string rateLabel: currentRate > 0 ? String(Math.round(currentRate)) : String(highRate)
  readonly property string monitorName: {
    if (!monitor) return ""
    var make = plain(monitor.make)
    var model = plain(monitor.model)
    if (make !== "" && model !== "") return make + " " + model
    return model !== "" ? model : make
  }
  readonly property string buttonText: (showIcon ? "󰍺 " : "") + (prefix !== "" ? prefix + " " : "") + rateLabel
  readonly property string tooltipText: available && monitor
    ? "External display · " + plain(outputName)
      + (monitorName !== "" ? " · " + monitorName : "")
      + " · " + monitor.width + "×" + monitor.height
      + " · " + rateLabel + " Hz — click for " + targetRate + " Hz"
    : "External display not connected"

  function plain(value) {
    return String(value || "").replace(/[<>]/g, "")
  }

  function boolSetting(name, fallback) {
    var value = setting(name, fallback)
    if (typeof value === "boolean") return value
    var text = String(value).toLowerCase()
    if (text === "true" || text === "1" || text === "yes" || text === "on") return true
    if (text === "false" || text === "0" || text === "no" || text === "off") return false
    return fallback !== false
  }

  function refresh() {
    if (!stateProc.running) stateProc.running = true
  }

  function applyMonitors(raw) {
    var list = []
    try { list = JSON.parse(String(raw || "")) } catch (e) { list = [] }
    if (!Array.isArray(list)) list = []

    var found = null
    for (var i = 0; i < list.length; i++) {
      var candidate = list[i]
      if (candidate && candidate.name === root.outputName && candidate.disabled !== true) {
        found = candidate
        break
      }
    }

    root.monitor = found
    root.available = found !== null
    root.currentRate = found ? Number(found.refreshRate) || 0 : 0
  }

  function findMode(width, height, target) {
    var modes = root.monitor && Array.isArray(root.monitor.availableModes)
      ? root.monitor.availableModes : []
    var bestMode = ""
    var bestDistance = 1e9

    for (var i = 0; i < modes.length; i++) {
      var mode = String(modes[i] || "")
      var match = mode.match(/^(\d+)x(\d+)@([0-9.]+)Hz$/)
      if (!match) continue
      if (Number(match[1]) !== Number(width) || Number(match[2]) !== Number(height)) continue

      var rate = Number(match[3])
      var distance = Math.abs(rate - target)
      if (distance < bestDistance) {
        bestDistance = distance
        bestMode = match[1] + "x" + match[2] + "@" + String(Math.round(rate))
      }
    }

    return bestMode !== "" ? bestMode : String(width) + "x" + String(height) + "@" + String(target)
  }

  function luaString(value) {
    return '"' + String(value).replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"'
  }

  function toggleRate() {
    if (!root.available || !root.monitor) return

    var monitor = root.monitor
    var mode = root.findMode(monitor.width, monitor.height, root.targetRate)
    var position = String(monitor.x) + "x" + String(monitor.y)
    var expression = "hl.monitor({ output = " + root.luaString(monitor.name)
      + ", mode = " + root.luaString(mode)
      + ", position = " + root.luaString(position)
      + ", scale = " + Number(monitor.scale)
      + (monitor.transform ? ", transform = " + Number(monitor.transform) : "")
      + " })"

    actionProc.command = ["hyprctl", "eval", expression]
    if (!actionProc.running) actionProc.running = true
  }

  visible: root.available
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Behavior on implicitWidth {
    NumberAnimation {
      duration: Style.duration(120)
      easing.type: Easing.OutCubic
    }
  }

  onSettingsChanged: root.refresh()

  Timer {
    id: refreshTimer
    interval: root.pollInterval * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Process {
    id: stateProc
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyMonitors(text)
    }
  }

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    onRunningChanged: if (!running) root.refresh()
  }

  ShellIpc {
    target: "miseriae.display-refresh"
    function refresh(): void { root.broadcast("refresh") }
    function toggle(): void { root.broadcast("toggleRate") }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.buttonText
    tooltipText: root.tooltipText
    active: root.available && root.isHigh
    activeColor: Color.accent
    horizontalMargin: 8.75
    verticalPadding: 8.75

    onPressed: function(pressedButton) {
      if (pressedButton === Qt.LeftButton) root.toggleRate()
      else if (pressedButton === Qt.MiddleButton) root.refresh()
    }
  }
}
