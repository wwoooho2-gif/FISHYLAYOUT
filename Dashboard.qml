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

  function runCursorAction(action) {
    cursorActionProcess.command = [
      decodeURIComponent(Qt.resolvedUrl("features/cursor-accent/cursor-accent").toString().replace(/^file:\/\//, "")),
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
            text: "Feature icons are on the bar. Manage the saved bar layout here."
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
              text: "Applies the saved icon arrangement and backs up your current bar settings."
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
