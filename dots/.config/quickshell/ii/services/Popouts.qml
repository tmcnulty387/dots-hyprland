pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.services

Singleton {
    id: root

    property var activePopouts: ({})

    readonly property real defaultOpacity: Config.options.popouts.defaultOpacity
    readonly property real minOpacity: Config.options.popouts.minOpacity
    readonly property real maxOpacity: Config.options.popouts.maxOpacity
    readonly property real scrollStep: Config.options.popouts.scrollStep

    function clampOpacity(value) {
        const candidate = isFinite(value) ? value : root.defaultOpacity;
        return Math.max(root.minOpacity, Math.min(root.maxOpacity, candidate));
    }

    function ensureState(popoutId) {
        if (!Persistent.states.popouts.instances) {
            Persistent.states.popouts.instances = {};
        }
        if (!Persistent.states.popouts.instances[popoutId]) {
            Persistent.states.popouts.instances[popoutId] = {
                x: Number.NaN,
                y: Number.NaN,
                opacity: root.defaultOpacity,
                screen: ""
            };
        }
        return Persistent.states.popouts.instances[popoutId];
    }

    function savePosition(popoutId, x, y, screenName) {
        const state = ensureState(popoutId);
        state.x = Math.round(x);
        state.y = Math.round(y);
        state.screen = screenName ?? state.screen ?? "";
    }

    function saveOpacity(popoutId, opacity) {
        const state = ensureState(popoutId);
        state.opacity = clampOpacity(opacity);
    }

    function releasePopout(popoutId, instance) {
        if (root.activePopouts[popoutId] === instance) {
            delete root.activePopouts[popoutId];
        }
    }

    function popout(popoutId, component, options = {}) {
        if (!popoutId || !component)
            return null;

        const existing = root.activePopouts[popoutId];
        if (existing)
            return existing;

        const popout = popoutWindowComponent.createObject(null, {
            popoutId,
            contentComponent: component,
            contentProperties: options.contentProperties ?? {},
            initialScreen: options.screen ?? null
        });
        if (popout) {
            root.activePopouts[popoutId] = popout;
            popout.closed.connect(() => root.releasePopout(popoutId, popout));
        }
        return popout;
    }

    Component {
        id: popoutWindowComponent

        PanelWindow {
            id: popoutWindow
            signal closed

            required property string popoutId
            required property Component contentComponent
            property var contentProperties: ({})
            property var initialScreen: null

            color: "transparent"
            visible: true
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            screen: initialScreen ?? Quickshell.screens[0] ?? null
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:popout"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            width: screen?.geometry?.width ?? 1920
            height: screen?.geometry?.height ?? 1080

            mask: Region {
                item: popoutSurface
            }

            readonly property var stateEntry: root.ensureState(popoutId)
            property bool hasPlacedOnce: false
            readonly property string currentScreenName: screen?.name ?? ""
            property real popoutOpacity: root.clampOpacity(stateEntry.opacity)

            onPopoutOpacityChanged: {
                root.saveOpacity(popoutId, popoutOpacity);
            }

            function closePopout() {
                popoutWindow.closed();
                popoutWindow.destroy();
            }

            function clampToWindow(value, min, max) {
                return Math.min(Math.max(value, min), max);
            }

            function contentWidth() {
                return contentLoader.item?.implicitWidth ?? contentLoader.implicitWidth ?? contentLoader.item?.width ?? 0;
            }

            function contentHeight() {
                return contentLoader.item?.implicitHeight ?? contentLoader.implicitHeight ?? contentLoader.item?.height ?? 0;
            }

            function placePopout(forceCenter = false) {
                if (!contentLoader.item)
                    return;

                const availableWidth = popoutWindow.width;
                const availableHeight = popoutWindow.height;
                const savedPositionValid = isFinite(stateEntry.x) && isFinite(stateEntry.y) && !forceCenter && stateEntry.screen === currentScreenName;

                const fallbackX = (availableWidth - popoutSurface.width) / 2;
                const fallbackY = (availableHeight - popoutSurface.height) / 2;

                const wantedX = savedPositionValid ? stateEntry.x : fallbackX;
                const wantedY = savedPositionValid ? stateEntry.y : fallbackY;

                const clampedX = clampToWindow(wantedX, 0, Math.max(0, availableWidth - popoutSurface.width));
                const clampedY = clampToWindow(wantedY, 0, Math.max(0, availableHeight - popoutSurface.height));

                popoutSurface.x = clampedX;
                popoutSurface.y = clampedY;
                root.savePosition(popoutId, clampedX, clampedY, currentScreenName);
                hasPlacedOnce = true;
            }

            Component.onCompleted: {
                Qt.callLater(() => placePopout(true));
            }

            onWidthChanged: {
                if (hasPlacedOnce)
                    placePopout();
            }
            onHeightChanged: {
                if (hasPlacedOnce)
                    placePopout();
            }
            onScreenChanged: {
                placePopout(true);
            }

            Component.onDestruction: {
                root.releasePopout(popoutId, popoutWindow);
            }

            Item {
                id: popoutLayer
                anchors.fill: parent

                Item {
                    id: popoutSurface
                    width: contentWidth()
                    height: contentHeight()
                    opacity: popoutWindow.popoutOpacity

                    Loader {
                        id: contentLoader
                        anchors.fill: parent
                        sourceComponent: popoutWindow.contentComponent
                        onLoaded: {
                            const item = contentLoader.item;
                            for (const key in popoutWindow.contentProperties) {
                                try {
                                    item[key] = popoutWindow.contentProperties[key];
                                } catch (e) {
                                    console.warn("[Popouts] Failed to assign property", key, e);
                                }
                            }
                            Qt.callLater(() => placePopout(!hasPlacedOnce));
                        }
                    }

                    DragHandler {
                        id: dragHandler
                        target: popoutSurface
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onActiveChanged: {
                            if (!active) {
                                root.savePosition(popoutId, popoutSurface.x, popoutSurface.y, currentScreenName);
                            }
                        }
                        xAxis.minimum: 0
                        xAxis.maximum: Math.max(0, popoutWindow.width - popoutSurface.width)
                        yAxis.minimum: 0
                        yAxis.maximum: Math.max(0, popoutWindow.height - popoutSurface.height)
                    }

                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: popoutWindow.closePopout()
                    }

                    WheelHandler {
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onWheel: (event) => {
                            const delta = event.angleDelta.y || event.pixelDelta.y;
                            if (!delta)
                                return;
                            const direction = delta > 0 ? 1 : -1;
                            popoutWindow.popoutOpacity = root.clampOpacity(popoutWindow.popoutOpacity + direction * root.scrollStep);
                            root.saveOpacity(popoutId, popoutWindow.popoutOpacity);
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }
}
