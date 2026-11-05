import QtQuick
import Quickshell

Item {
  id: root

  property var bar: null
  property string moduleName: ""
  property var settings: ({})
  property string fixedEdge: "center"

  readonly property string featurePath: {
    var path = String(settings.featurePath || "")
    var home = Quickshell.env("HOME")
    if (path.indexOf("~/") === 0)
      return home + path.substring(1)
    if (path.indexOf("$HOME/") === 0)
      return home + path.substring(5)
    return path
  }
  readonly property var feature: featureLoader.item

  function injectFeature() {
    var target = featureLoader.item
    if (!target)
      return
    if ("bar" in target)
      target.bar = root.bar
    if ("moduleName" in target)
      target.moduleName = root.moduleName
    if ("fixedEdge" in target)
      target.fixedEdge = root.fixedEdge
    if ("settings" in target)
      target.settings = root.settings
  }

  implicitWidth: feature && feature.visible ? feature.implicitWidth : 0
  implicitHeight: feature ? feature.implicitHeight : (bar ? bar.barSize : 26)

  onBarChanged: injectFeature()
  onSettingsChanged: injectFeature()

  Loader {
    id: featureLoader
    width: item ? item.implicitWidth : 0
    height: item ? item.implicitHeight : (root.bar ? root.bar.barSize : 26)
    source: root.featurePath ? Qt.resolvedUrl(root.featurePath) : ""
    onLoaded: root.injectFeature()
  }
}
