import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  moduleName: "furina.omarchy-suite"

  property var dashboard: null

  readonly property bool opened: dashboard ? dashboard.opened === true : false

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

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectDashboard()
  onSettingsChanged: injectDashboard()

  Loader {
    id: dashboardLoader
    active: true
    source: Qt.resolvedUrl("Dashboard.qml")
    visible: false

    onLoaded: {
      root.injectDashboard()
      Qt.callLater(root.injectDashboard)
    }
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
    anchors.fill: parent
    bar: root.bar
    text: "󰍜"
    tooltipText: "FISHYLAYOUT"

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton)
        root.toggleDashboard()
    }
  }
}
