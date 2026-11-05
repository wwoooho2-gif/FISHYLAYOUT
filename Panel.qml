import QtQuick
import "features/alt-tab" as AltTabFeature
import "features/taskbar" as TaskbarFeature

Item {
  id: root

  property var shell: null
  property var manifest: null

  TaskbarFeature.Taskbar {
    shell: root.shell
    manifest: root.manifest
  }

  AltTabFeature.Main {
    shell: root.shell
    manifest: root.manifest
  }
}
