import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "furina.omarchy-suite"

  property var dashboard: null
  readonly property bool opened: dashboard ? dashboard.opened === true : false
  readonly property bool popoutSwitchClosing: dashboard ? dashboard.popoutSwitchClosing === true : false

  function injectDashboard() {
    if (!dashboardLoader.item)
      return

    dashboard = dashboardLoader.item
    dashboard.bar = root.bar
    dashboard.settings = root.settings
    dashboard.anchorItem = button
    dashboard.hostWidget = root
  }

  function toggleDashboard() {
    if (dashboard)
      dashboard.toggle()
  }

  function open() {
    if (dashboard)
      dashboard.open()
  }

  function close() {
    if (dashboard)
      dashboard.close()
  }

  function closeForPopoutSwitch() {
    if (dashboard)
      dashboard.closeForPopoutSwitch()
  }

  Timer {
    id: dashboardInjectionTimer
    interval: 0
    onTriggered: root.injectDashboard()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: dashboardInjectionTimer.restart()
  onSettingsChanged: dashboardInjectionTimer.restart()

  Loader {
    id: dashboardLoader
    active: true
    source: Qt.resolvedUrl("Dashboard.qml")
    visible: false

    onLoaded: dashboardInjectionTimer.restart()
  }

  IpcHandler {
    target: "furina.omarchy-suite"

    function open(): void {
      if (root.dashboard)
        root.dashboard.open()
    }

    function close(): void {
      if (root.dashboard)
        root.dashboard.close()
    }

    function toggle(): void {
      root.toggleDashboard()
    }
  }

  BarIconButton {
    id: button
    bar: root.bar
    text: "󰍜"
    tooltipText: "FISHYLAYOUT"
    width: implicitWidth
    height: implicitHeight

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton)
        root.toggleDashboard()
    }
  }
}
