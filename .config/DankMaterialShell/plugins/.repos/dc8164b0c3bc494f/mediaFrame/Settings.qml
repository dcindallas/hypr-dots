import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins
import qs.Widgets
import qs.Modals.FileBrowser

PluginSettings {
  id: root
  pluginId: "mediaFrame"

  property bool enableBorder: root.loadValue("enableBorder", false)
  property string imagePath: root.loadValue("imagePath", "")
  property string imageFillMode: root.loadValue("imageFillMode", "PreserveAspectFit")

  // Loader for the file bowser
  LazyLoader {
    id: imageBrowserLoader
    active: false

    FileBrowserModal {
      browserTitle: I18n.tr("Select picture")
      browserIcon: "image"
      fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.webp"]
      onFileSelected: path => {
        root.saveValue("imagePath", path)
        close();
      }
    }
  }

  // Image Settings
  StyledText {
    text: I18n.tr("Image Settings")
    font.pixelSize: Theme.fontSizeLarge
    font.weight: Font.Medium
    color: Theme.surfaceText
  }

  DankButton {
    text: I18n.tr("Select image")
    iconName: "image"
    width: parent.width
    onClicked: {
      imageBrowserLoader.active = true;
      if (imageBrowserLoader.item) {
        imageBrowserLoader.item.open();
      }
    }
  }
  StyledText {
    text: I18n.tr("Current image: ") + String(root.imagePath)
    font.pixelSize: Theme.fontSizeSmall
    color: Theme.surfaceVariantText
    wrapMode: Text.WrapAnywhere
  }

  SelectionSetting {
    settingKey: "fillMode"
    label: I18n.tr("Fill mode")
    description: I18n.tr("Fill mode used for the image")
    options: [
      {label: I18n.tr("Stretch"), value: "Stretch"},
      {label: I18n.tr("(Fit) Aspect Ratio"), value: "PreserveAspectFit"},
      {label: I18n.tr("(Crop) Aspect Ratio"), value: "PreserveAspectCrop"},
      {label: I18n.tr("Tile"), value: "Tile"},
      {label: I18n.tr("Tile Vertically"), value: "TileVertically"},
      {label: I18n.tr("Tile Horizontally"), value: "TileHorizontally"},
      {label: I18n.tr("No transform"), value: "Pad"}
    ]
    defaultValue: "PreserveAspectFit"
  }

  // Appearence Settings
  StyledText {
    text: I18n.tr("Appearence Settings")
    font.pixelSize: Theme.fontSizeLarge
    font.weight: Font.Medium
    color: Theme.surfaceText
  }

  SliderSetting {
    settingKey: "backgroundOpacity"
    label: I18n.tr("Background Opacity")
    defaultValue: 50
    minimum: 0
    maximum: 100
    unit: "%"
  }

  ToggleSetting {
    settingKey: "enableBorder"
    label: I18n.tr("Border")
    defaultValue: root.enableBorder
  }

  SelectionSetting {
    enabled: root.enableBorder
    opacity: enableBorder ? 1.0 : 0.2
    settingKey: "borderColor"
    label: I18n.tr("Border Color")
    description: I18n.tr("")
    options: [
      {label: I18n.tr("Primary"), value: "primary"},
      {label: I18n.tr("Secondary"), value: "secondary"},
      {label: I18n.tr("Surface"), value: "surface"},
    ]
    defaultValue: "primary"
  }

  SliderSetting {
    enabled: root.enableBorder
    opacity: root.enableBorder ? 1.0 : 0.2
    settingKey: "borderOpacity"
    label: I18n.tr("Border Opacity")
    defaultValue: 100
    minimum: 0
    maximum: 100
    unit: "%"
  }

  SliderSetting {
    enabled: root.enableBorder
    opacity: root.enableBorder ? 1.0 : 0.2
    settingKey: "borderThickness"
    label: I18n.tr("Border Thickness")
    defaultValue: 2
    minimum: 1
    maximum: 10
    unit: "px"
  }

  StringSetting {
    settingKey: "frameRadius"
    label: I18n.tr("Corner radius")
    description: I18n.tr("Plugin's corner radius")
    placeholder: Theme.cornerRadius
    defaultValue: Theme.cornerRadius
  }
}
