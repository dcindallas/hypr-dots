import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
  id: root

  // Size constraints
  minWidth: 150
  minHeight: 100

  // Access saved settings via pluginData
  property string imagePath: String(pluginData.imagePath).replace(/~/g, String(Quickshell.env("HOME"))) ?? ""
  property real backgroundOpacity: (pluginData.backgroundOpacity ?? 80) / 100
  property real frameRadius: pluginData.frameRadius ?? Theme.cornerRadius
  property string imageFillMode: pluginData.fillMode ?? "PreserveAspectFit"
  // Border
  property bool enableBorder: pluginData.enableBorder ?? false
  property int borderThickness: pluginData.borderThickness ?? 2
  property real borderOpacity: (pluginData.borderOpacity ?? 100) / 100
  property string borderColor: pluginData.borderColor ?? "primary"
  property color resolvedBorderColor: {
    if (root.borderColor === "primary") {
      return Theme.primary
    }
    
    else if (root.borderColor === "secondary") {
      return Theme.secondary
    }
    
    else if (root.borderColor === "surface") {
      return Theme.surfaceText
    }
  }


  Rectangle {
    id: background
    anchors.fill: parent
    radius: root.frameRadius
    color: Theme.withAlpha(Theme.surfaceContainer, root.backgroundOpacity)
    border.color: root.enableBorder ? Theme.withAlpha(root.resolvedBorderColor, root.borderOpacity) : "transparent"
    border.width: root.enableBorder ? root.borderThickness : 0

    Image {
      id: image
      anchors.centerIn: parent
      height: parent.height - root.borderThickness
      width: parent.width - root.borderThickness
      source: root.imagePath
      fillMode: Image[root.imageFillMode]
      asynchronous: true
      cache: true
      visible: true
    }
  }
}
