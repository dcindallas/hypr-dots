import QtQuick
import Quickshell
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "dankGifSearch"
    property string trigger: "gif"
    property string lastSentQuery: "\x00"
    property string pendingQuery: "\x00"

    signal itemsChanged

    property Timer searchDebounce: Timer {
        interval: 300
        repeat: false
        onTriggered: {
            if (root.pendingQuery !== root.lastSentQuery) {
                root.lastSentQuery = root.pendingQuery;
                if (!root.pendingQuery) {
                    GifSearchService.trending();
                } else {
                    GifSearchService.search(root.pendingQuery);
                }
            }
        }
    }

    property Connections gifConn: Connections {
        target: GifSearchService

        function onResultsReady() {
            if (!pluginService || !pluginId)
                return;
            if (typeof pluginService.requestLauncherUpdate === "function") {
                pluginService.requestLauncherUpdate(pluginId);
            }
        }
    }

    Component.onCompleted: {
        if (!pluginService)
            return;
        trigger = pluginService.loadPluginData("dankGifSearch", "trigger", "gif");
    }

    onTriggerChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData("dankGifSearch", "trigger", trigger);
    }

    function getItems(query) {
        const q = (query || "").trim();

        if (q !== pendingQuery) {
            pendingQuery = q;
            searchDebounce.restart();
        }

        if (GifSearchService.loading || q !== lastSentQuery) {
            return [
                {
                    name: I18n.tr("Searching..."),
                    icon: "material:hourglass_empty",
                    comment: q || I18n.tr("Trending GIFs"),
                    action: "none",
                    categories: ["GIF Search"]
                }
            ];
        }

        const results = GifSearchService.results;
        if (!results || results.length === 0) {
            return [
                {
                    name: q ? I18n.tr("No results found") : I18n.tr("Loading trending..."),
                    icon: "material:gif_box",
                    comment: I18n.tr("Try a different search"),
                    action: "none",
                    categories: ["GIF Search"]
                }
            ];
        }

        const pluginDir = pluginService?.getPluginPath?.("dankGifSearch") || "";
        const attributionSvg = pluginDir ? pluginDir + "/klippy.svg" : "";

        const items = [];
        for (let i = 0; i < results.length; i++) {
            const gif = results[i];
            items.push({
                name: gif.title || "GIF",
                icon: "material:gif",
                comment: I18n.tr("Shift+Enter to paste"),
                action: "copy:" + gif.originalUrl,
                categories: ["GIF Search"],
                imageUrl: gif.previewUrl,
                animated: true,
                attribution: attributionSvg
            });
        }
        return items;
    }

    function getPasteText(item) {
        if (!item?.action)
            return null;
        if (!item.action.startsWith("copy:"))
            return null;
        return item.action.substring(5);
    }

    function executeItem(item) {
        if (!item?.action)
            return;
        if (!item.action.startsWith("copy:"))
            return;
        const url = item.action.substring(5);
        Quickshell.execDetached(["dms", "cl", "copy", url]);
        ToastService.showInfo(I18n.tr("Copied to clipboard"));
    }

    function getContextMenuActions(item) {
        if (!item)
            return [];

        const gifUrl = item.action?.startsWith("copy:") ? item.action.substring(5) : "";
        if (!gifUrl)
            return [];

        return [
            {
                icon: "content_copy",
                text: I18n.tr("Copy URL"),
                action: () => {
                    Quickshell.execDetached(["dms", "cl", "copy", gifUrl]);
                    ToastService.showInfo(I18n.tr("Copied to clipboard"));
                }
            },
            {
                icon: "open_in_new",
                text: I18n.tr("Open in Browser"),
                action: () => {
                    Qt.openUrlExternally(gifUrl);
                }
            }
        ];
    }
}
