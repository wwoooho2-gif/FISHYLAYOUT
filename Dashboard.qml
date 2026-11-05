import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root

  moduleName: "furina.omarchy-suite"
  ipcTarget: "furina.omarchy-suite"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string layoutPresetStatus: ""
  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  function inject(loader) {
    if (!loader.item)
      return
    if ("bar" in loader.item)
      loader.item.bar = root.bar
    if ("settings" in loader.item)
      loader.item.settings = root.settings
  }

  function runCursorAction(action) {
    cursorActionProcess.command = [
      Qt.resolvedUrl("features/cursor-accent/cursor-accent").toString().replace(/^file:\/\//, ""),
      action
    ]
    cursorActionProcess.running = true
  }

  function applyLayoutPreset() {
    if (layoutPresetProcess.running)
      return
    layoutPresetStatus = "Applying bar layout…"
    layoutPresetProcess.command = [
      "bash",
      decodeURIComponent(String(Qt.resolvedUrl("presets/apply-current-layout.sh")).replace(/^file:\/\//, ""))
    ]
    layoutPresetProcess.running = true
  }

  Process {
    id: cursorActionProcess

    onExited: function(exitCode) {
      if (exitCode !== 0)
        console.warn("Omarchy Suite: cursor command failed with exit code " + exitCode)
    }
  }

  Process {
    id: layoutPresetProcess

    stdout: StdioCollector {
      id: layoutPresetStdout
      waitForEnd: true
    }

    stderr: StdioCollector {
      id: layoutPresetStderr
      waitForEnd: true
    }

    onExited: function(exitCode) {
      var output = String(exitCode === 0 ? layoutPresetStdout.text : layoutPresetStderr.text).trim()
      root.layoutPresetStatus = exitCode === 0
        ? (output || "Bar layout applied. The FISHYLAYOUT icon stays on the bar.")
        : (output || "Could not apply the bar layout.")
      if (exitCode !== 0)
        console.warn("FISHYLAYOUT: could not apply the bar preset:", output || "unknown error")
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    contentWidth: popup.fittedContentWidth(Style.space(560))
    contentHeight: popup.fittedContentHeight(contentColumn.implicitHeight, Style.space(620))
    focusTarget: keyCatcher

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
          id: contentColumn
          width: parent.width
          spacing: Style.space(14)

          Text {
            Layout.fillWidth: true
            text: "FISHYLAYOUT"
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            Layout.fillWidth: true
            text: "Open a bundled feature. Its control panel appears after you select it."
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.WordWrap
            opacity: 0.75
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.space(10)

            Button {
              text: layoutPresetProcess.running ? "Applying preset…" : "Apply bar preset"
              enabled: !layoutPresetProcess.running
              onClicked: root.applyLayoutPreset()
            }

            Text {
              Layout.fillWidth: true
              text: "Applies the saved bar layout and backs up your current settings. Standalone plugin icons appear only if those plugins are installed."
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
              wrapMode: Text.WordWrap
              opacity: 0.75
            }
          }

          Text {
            Layout.fillWidth: true
            visible: root.layoutPresetStatus !== ""
            text: root.layoutPresetStatus
            textFormat: Text.PlainText
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Style.space(10)
            rowSpacing: Style.space(10)

            Repeater {
              model: [
                { label: "Plugin Manager", source: "features/plugin-manager/BarWidget.qml" },
                { label: "Quick Drawer", source: "features/quick-drawer/Indicators.qml" },
                { label: "GPU Monitor", source: "features/gpu-monitor/BarWidget.qml" },
                { label: "Media Controls", source: "features/better-media/BarWidget.qml" },
                { label: "Glass & Blur", source: "features/glass-blur/Panel.qml" }
              ]

              delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: Style.space(82)
                color: "transparent"

                ColumnLayout {
                  anchors.fill: parent
                  spacing: Style.space(5)

                  Text {
                    Layout.fillWidth: true
                    text: modelData.label
                    color: root.contentForeground
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.caption
                    horizontalAlignment: Text.AlignHCenter
                  }

                  Loader {
                    id: featureLoader
                    active: root.opened
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: item ? Math.max(item.implicitWidth, Style.space(44)) : Style.space(44)
                    Layout.preferredHeight: item ? Math.max(item.implicitHeight, Style.space(32)) : Style.space(32)
                    source: Qt.resolvedUrl(modelData.source)
                    onLoaded: root.inject(featureLoader)
                  }
                }
              }
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.space(8)

            Text {
              text: "Workspace preview"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
            }

            Item {
              Layout.fillWidth: true
            }

            Loader {
              id: workspaceLoader
              active: root.opened
              source: Qt.resolvedUrl("features/workspace-preview/WorkspacePreview.qml")
              Layout.preferredWidth: item ? item.implicitWidth : 0
              Layout.preferredHeight: item ? item.implicitHeight : 0
              onLoaded: root.inject(workspaceLoader)
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.space(8)

            Text {
              Layout.fillWidth: true
              text: "Cursor accent"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
            }

            Button {
              text: "Follow theme"
              onClicked: root.runCursorAction("follow")
            }

            Button {
              text: "Default"
              onClicked: root.runCursorAction("default")
            }
          }

          Text {
            Layout.fillWidth: true
            text: "Omarchy Taskbar is enabled as the suite's bottom bar."
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
            opacity: 0.75
          }
        }
      }
    }
  }
}
