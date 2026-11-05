import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  moduleName: "furina.omarchy-suite"

  property var dashboard: null
  readonly property string segment: String(root.setting("segment", "left"))
  readonly property bool rightSegment: segment === "right"
  readonly property var featurePaths: rightSegment
    ? ["features/gpu-monitor/BarWidget.qml"]
    : [
        "features/quick-drawer/Indicators.qml",
        "features/plugin-manager/BarWidget.qml",
        "features/glass-blur/Panel.qml",
        "features/workspace-preview/WorkspacePreview.qml"
      ]

  readonly property bool opened: dashboard ? dashboard.opened === true : false
  readonly property bool popoutSwitchClosing: dashboard ? dashboard.popoutSwitchClosing === true : false

  function injectDashboard() {
    if (rightSegment) {
      dashboard = null
      return
    }
    if (!dashboardLoader.item)
      return

    dashboard = dashboardLoader.item
    dashboard.bar = root.bar
    dashboard.settings = root.settings
    dashboard.anchorItem = button
    dashboard.hostWidget = root
  }

  function injectFeature(loader) {
    if (!loader || !loader.item)
      return
    if ("bar" in loader.item)
      loader.item.bar = root.bar
    if ("settings" in loader.item) {
      if (String(loader.modelData).indexOf("features/quick-drawer/") === 0) {
        loader.item.settings = {
          items: [
            "caffeine",
            "nightlight",
            "dnd",
            "screensaver",
            "suspend",
            {
              id: "suite-plugin-manager",
              label: "Plugin Manager",
              icon: "\uf1e6",
              command: "omarchy-shell furina.omarchy-suite.plugin-manager toggle"
            },
            "ext:io.github.salemsayed.omawarden"
          ]
        }
      } else {
        loader.item.settings = ({})
      }
    }
  }

  function injectFeatures() {
    for (var i = 0; i < featureRepeater.count; i++)
      injectFeature(featureRepeater.itemAt(i))

    var drawer = null
    var manager = null
    for (var j = 0; j < featureRepeater.count; j++) {
      var loader = featureRepeater.itemAt(j)
      if (!loader || !loader.item) continue
      if (String(loader.modelData).indexOf("features/quick-drawer/") === 0)
        drawer = loader.item
      else if (String(loader.modelData).indexOf("features/plugin-manager/") === 0)
        manager = loader.item
    }
    if (drawer && manager && "externalAnchorItem" in manager)
      manager.externalAnchorItem = drawer.barAnchorItem
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

  implicitWidth: iconRow.implicitWidth
  implicitHeight: iconRow.implicitHeight

  onBarChanged: {
    injectDashboard()
    injectFeatures()
  }
  onSettingsChanged: {
    injectDashboard()
    injectFeatures()
  }

  Loader {
    id: dashboardLoader
    active: !root.rightSegment
    source: Qt.resolvedUrl("Dashboard.qml")
    visible: false

    onLoaded: {
      root.injectDashboard()
      Qt.callLater(root.injectDashboard)
    }
  }

  IpcHandler {
    target: root.rightSegment ? "furina.omarchy-suite.right" : "furina.omarchy-suite"

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

  Row {
    id: iconRow
    anchors.fill: parent
    spacing: 0

    Repeater {
      id: featureRepeater
      model: root.featurePaths

      delegate: Loader {
        id: featureLoader
        required property string modelData
        source: Qt.resolvedUrl(modelData)
        width: item && item.visible ? item.implicitWidth : 0
        height: root.bar ? root.bar.barSize : Style.bar.sizeHorizontal

        onLoaded: {
          root.injectFeature(featureLoader)
          Qt.callLater(root.injectFeatures)
        }
      }
    }

    BarIconButton {
      id: button
      bar: root.bar
      text: "󰍜"
      tooltipText: "FISHYLAYOUT"
      width: implicitWidth
      height: implicitHeight
      visible: !root.rightSegment

      onPressed: function(mouseButton) {
        if (mouseButton === Qt.LeftButton)
          root.toggleDashboard()
      }
    }
  }
}
