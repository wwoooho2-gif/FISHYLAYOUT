import QtQuick
import "features/better-media" as MediaFeature
import "features/cursor-accent" as CursorFeature

Item {
  id: root

  property var shell: null

  MediaFeature.Service {
    shell: root.shell
  }

  CursorFeature.Service {}
}
