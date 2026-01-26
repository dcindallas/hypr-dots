import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "./components"

PluginComponent {
    id: root

    property string selectedDeviceId: pluginData.selectedDeviceId || ""
    property bool showShareDialog: false
    property string shareDeviceId: ""

    readonly property var selectedDevice: selectedDeviceId ? KDEConnectService.devices[selectedDeviceId] ?? null : null
    readonly property bool hasDevice: selectedDevice !== null

    ccWidgetIcon: {
        if (!KDEConnectService.available)
            return "phonelink_off";
        if (hasDevice && selectedDevice.isReachable)
            return "phonelink";
        return "phonelink_off";
    }
    ccWidgetPrimaryText: "KDE Connect"
    ccWidgetSecondaryText: {
        if (!KDEConnectService.available)
            return I18n.tr("Unavailable", "KDE Connect unavailable status");
        if (!hasDevice)
            return I18n.tr("No devices", "KDE Connect no devices status");
        if (selectedDevice.isReachable) {
            let text = selectedDevice.name;
            if (selectedDevice.batteryCharge >= 0)
                text += " • " + selectedDevice.batteryCharge + "%";
            return text;
        }
        return selectedDevice.name + " (" + I18n.tr("Offline", "KDE Connect offline status") + ")";
    }
    ccWidgetIsActive: hasDevice && selectedDevice?.isReachable

    ccDetailContent: Component {
        KDEConnectDetailContent {
            listHeight: 200
        }
    }

    onPluginServiceChanged: {
        if (!pluginService)
            return;
        const savedId = pluginService.loadPluginData("dankKDEConnect", "selectedDeviceId", "");
        if (savedId)
            selectedDeviceId = savedId;
    }

    Connections {
        target: KDEConnectService
        function onDevicesListChanged() {
            if (!selectedDeviceId && KDEConnectService.deviceIds.length > 0) {
                selectDevice(KDEConnectService.deviceIds[0]);
            }
        }

        function onPairingRequestReceived(deviceId, verificationKey) {
            const device = KDEConnectService.getDevice(deviceId);
            ToastService.showInfo(I18n.tr("Pairing request from", "KDE Connect pairing request notification") + " " + (device?.name || deviceId), I18n.tr("Verification", "KDE Connect pairing verification key label") + ": " + verificationKey);
        }

        function onShareReceived(deviceId, url) {
            const device = KDEConnectService.getDevice(deviceId);
            const filename = url.split("/").pop() || url;
            const filePath = url.startsWith("file://") ? url.substring(7) : url;

            Quickshell.execDetached(["dms", "notify", "--app", "KDE Connect", "--icon", "smartphone", "--file", filePath, I18n.tr("File received from", "KDE Connect file share notification") + " " + (device?.name || deviceId), filename]);
        }
    }

    function selectDevice(deviceId) {
        selectedDeviceId = deviceId;
        if (pluginService) {
            pluginService.savePluginData("dankKDEConnect", "selectedDeviceId", deviceId);
        }
    }

    function handleAction(deviceId, action) {
        const device = KDEConnectService.getDevice(deviceId);
        const deviceName = device?.name || I18n.tr("device", "Generic device name fallback");
        switch (action) {
        case "ring":
            KDEConnectService.ringDevice(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Failed to ring device", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Ringing", "KDE Connect ring action") + " " + deviceName + "...");
            });
            break;
        case "ping":
            KDEConnectService.sendPing(deviceId, "", response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Failed to send ping", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Ping sent to", "KDE Connect ping action") + " " + deviceName);
            });
            break;
        case "clipboard":
            KDEConnectService.sendClipboard(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Failed to send clipboard", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Clipboard sent", "KDE Connect clipboard action"));
            });
            break;
        case "share":
            shareDeviceId = deviceId;
            showShareDialog = true;
            break;
        case "sms":
            closePopout();
            KDEConnectService.launchSmsApp(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Failed to launch SMS app", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Opening SMS app", "KDE Connect SMS action") + "...");
            });
            break;
        case "browse":
            closePopout();
            KDEConnectService.startBrowsing(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Failed to browse device", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Opening file browser", "KDE Connect browse action") + "...");
            });
            break;
        case "pair":
            KDEConnectService.requestPairing(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Pairing failed", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Pairing request sent", "KDE Connect pairing action"));
            });
            break;
        case "acceptPair":
            KDEConnectService.acceptPairing(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Failed to accept pairing", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Device paired", "KDE Connect pairing action"));
            });
            break;
        case "rejectPair":
            KDEConnectService.cancelPairing(deviceId, response => {
                if (response.error)
                    ToastService.showError(I18n.tr("Failed to reject pairing", "KDE Connect error"), response.error);
            });
            break;
        case "unpair":
            KDEConnectService.unpair(deviceId, response => {
                if (response.error) {
                    ToastService.showError(I18n.tr("Unpair failed", "KDE Connect error"), response.error);
                    return;
                }
                ToastService.showInfo(I18n.tr("Device unpaired", "KDE Connect unpair action"));
            });
            break;
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: (root.barConfig?.noBackground ?? false) ? 1 : 2

            Item {
                width: phoneIcon.width
                height: phoneIcon.height
                anchors.verticalCenter: parent.verticalCenter

                DankIcon {
                    id: phoneIcon
                    name: root.hasDevice && root.selectedDevice.isReachable ? "smartphone" : "phonelink_off"
                    size: Theme.barIconSize(root.barThickness, -4)
                    color: {
                        if (!KDEConnectService.available)
                            return Theme.widgetIconColor;
                        if (root.hasDevice && root.selectedDevice?.isReachable && root.selectedDevice?.batteryCharging)
                            return Theme.primary;
                        return Theme.widgetIconColor;
                    }
                }

                DankIcon {
                    visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharging ?? false)
                    name: "bolt"
                    size: phoneIcon.size * 0.45
                    color: Theme.primary
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -2
                    anchors.bottomMargin: -1
                }
            }

            StyledText {
                visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharge ?? -1) >= 0
                text: (root.selectedDevice?.batteryCharge ?? 0) + "%"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: !KDEConnectService.available
                text: "N/A"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            Item {
                width: phoneIconV.width
                height: phoneIconV.height
                anchors.horizontalCenter: parent.horizontalCenter

                DankIcon {
                    id: phoneIconV
                    name: root.hasDevice && root.selectedDevice.isReachable ? "smartphone" : "phonelink_off"
                    size: Theme.barIconSize(root.barThickness)
                    color: {
                        if (!KDEConnectService.available)
                            return Theme.widgetIconColor;
                        if (root.hasDevice && root.selectedDevice?.isReachable && root.selectedDevice?.batteryCharging)
                            return Theme.primary;
                        return Theme.widgetIconColor;
                    }
                }

                DankIcon {
                    visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharging ?? false)
                    name: "bolt"
                    size: phoneIconV.size * 0.45
                    color: Theme.primary
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -2
                    anchors.bottomMargin: -1
                }
            }

            StyledText {
                visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharge ?? -1) >= 0
                text: (root.selectedDevice?.batteryCharge ?? 0).toString()
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "KDE Connect"
            detailsText: KDEConnectService.connectedCount + " connected • " + KDEConnectService.pairedCount + " paired"
            showCloseButton: true
            headerActions: Component {
                DankActionButton {
                    iconName: KDEConnectService.isRefreshing ? "sync" : "refresh"
                    iconColor: Theme.surfaceVariantText
                    buttonSize: 28
                    enabled: !KDEConnectService.isRefreshing
                    tooltipText: I18n.tr("Refresh", "KDE Connect refresh tooltip")
                    tooltipSide: "bottom"
                    onClicked: KDEConnectService.refreshDevices()
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM

                UnavailableMessage {
                    visible: !KDEConnectService.available
                    width: parent.width
                }

                EmptyState {
                    visible: KDEConnectService.available && KDEConnectService.deviceIds.length === 0
                    width: parent.width
                }

                Repeater {
                    model: KDEConnectService.deviceIds

                    DeviceCard {
                        required property string modelData
                        width: parent.width
                        deviceId: modelData
                        device: KDEConnectService.getDevice(modelData)
                        isSelected: root.selectedDeviceId === modelData
                        onClicked: root.selectDevice(modelData)
                        onAction: action => root.handleAction(modelData, action)
                    }
                }

                ShareDialog {
                    visible: root.showShareDialog
                    width: parent.width
                    deviceId: root.shareDeviceId
                    parentPopout: popout.parentPopout
                    onClose: root.showShareDialog = false
                    onShare: (content, isUrl) => {
                        if (isUrl) {
                            KDEConnectService.shareUrl(root.shareDeviceId, content, response => {
                                if (response.error) {
                                    ToastService.showError(I18n.tr("Failed to share", "KDE Connect error"), response.error);
                                    return;
                                }
                                ToastService.showInfo(I18n.tr("Shared", "KDE Connect share success"));
                            });
                        } else {
                            KDEConnectService.shareText(root.shareDeviceId, content, response => {
                                if (response.error) {
                                    ToastService.showError(I18n.tr("Failed to share", "KDE Connect error"), response.error);
                                    return;
                                }
                                ToastService.showInfo(I18n.tr("Shared", "KDE Connect share success"));
                            });
                        }
                        root.showShareDialog = false;
                    }
                    onShareFile: path => {
                        const fileUrl = "file://" + path;
                        KDEConnectService.shareUrl(root.shareDeviceId, fileUrl, response => {
                            if (response.error) {
                                ToastService.showError(I18n.tr("Failed to send file", "KDE Connect error"), response.error);
                                return;
                            }
                            const filename = path.split("/").pop();
                            ToastService.showInfo(I18n.tr("Sending", "KDE Connect file send") + " " + filename + "...");
                        });
                        root.showShareDialog = false;
                    }
                }
            }
        }
    }
}
