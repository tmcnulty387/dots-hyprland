import QtQuick
import Quickshell
import qs.services

Item {
    id: root

    property string popoutId: ""
    property Component contentComponent
    property var popoutProperties: ({})
    property bool enablePopout: true

    implicitWidth: contentLoader.item ? contentLoader.item.implicitWidth : contentLoader.implicitWidth
    implicitHeight: contentLoader.item ? contentLoader.item.implicitHeight : contentLoader.implicitHeight

    Loader {
        id: contentLoader
        anchors.fill: parent
        sourceComponent: root.contentComponent
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        acceptedModifiers: Qt.ControlModifier
        gesturePolicy: TapHandler.DragThreshold
        onTapped: root.triggerPopout()
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        gesturePolicy: TapHandler.DragThreshold
        onTapped: root.triggerPopout()
    }

    function triggerPopout() {
        if (!enablePopout || !contentComponent)
            return;
        Popouts.popout(popoutId, contentComponent, {
            screen: root.QsWindow?.window?.screen ?? null,
            contentProperties: popoutProperties
        });
    }
}
