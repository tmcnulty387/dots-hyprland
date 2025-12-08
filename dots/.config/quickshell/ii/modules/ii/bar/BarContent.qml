import qs.modules.ii.bar.weather
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item { // Bar content region
    id: root

    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
    property real useShortenedForm: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen?.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen?.width) ? 1 : 0
    readonly property int centerSideModuleWidth: (useShortenedForm == 2) ? Appearance.sizes.barCenterSideModuleWidthHellaShortened : (useShortenedForm == 1) ? Appearance.sizes.barCenterSideModuleWidthShortened : Appearance.sizes.barCenterSideModuleWidth
    readonly property var barWindow: root.QsWindow?.window
    property string reminderDraft: GlobalStates.barReminderText
    property bool reminderEditing: false

    Component.onCompleted: reminderDraft = GlobalStates.barReminderText

    function cancelReminderEditing() {
        reminderDraft = GlobalStates.barReminderText;
        reminderEditing = false;
        if (reminderField) {
            reminderField.deselect();
            if (reminderField.focus)
                reminderField.focus = false;
        }
    }

    HyprlandFocusGrab {
        id: reminderFocusGrab
        windows: barWindow ? [barWindow] : []
        active: reminderEditing && !!barWindow
        onCleared: {
            if (reminderEditing) {
                root.cancelReminderEditing();
            }
        }
    }

    Connections {
        target: GlobalStates
        function onBarReminderTextChanged() {
            if (!root.reminderEditing) {
                root.reminderDraft = GlobalStates.barReminderText;
            }
        }
    }

    component VerticalBarSeparator: Rectangle {
        Layout.topMargin: Appearance.sizes.baseBarHeight / 3
        Layout.bottomMargin: Appearance.sizes.baseBarHeight / 3
        Layout.fillHeight: true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
    }

    // Background shadow
    Loader {
        active: Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1 && Config.options.bar.floatStyleShadow
        anchors.fill: barBackground
        sourceComponent: StyledRectangularShadow {
            anchors.fill: undefined // The loader's anchors act on this, and this should not have any anchor
            target: barBackground
        }
    }
    // Background
    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            margins: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut) : 0 // idk why but +1 is needed
        }
        color: Config.options.bar.showBackground ? Appearance.colors.colLayer0 : "transparent"
        radius: Config.options.bar.cornerStyle === 1 ? Appearance.rounding.windowRounding : 0
        border.width: Config.options.bar.cornerStyle === 1 ? 1 : 0
        border.color: Appearance.colors.colLayer0Border
    }

    FocusedScrollMouseArea { // Left side | scroll to change brightness
        id: barLeftSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: middleSection.left
        }
        implicitWidth: leftSectionRowLayout.implicitWidth
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness - 0.05)
        onScrollUp: root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness + 0.05)
        onMovedAway: GlobalStates.osdBrightnessOpen = false
        onPressed: event => {
            if (root.reminderEditing)
                root.cancelReminderEditing();
            if (event.button === Qt.LeftButton)
                GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
        }

        // Visual content
        ScrollHint {
            reveal: barLeftSideMouseArea.hovered
            icon: "light_mode"
            tooltipText: Translation.tr("Scroll to change brightness")
            side: "left"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: leftSectionRowLayout
            anchors.fill: parent
            spacing: 10

            LeftSidebarButton { // Left sidebar button
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: Appearance.rounding.screenRounding
                colBackground: barLeftSideMouseArea.hovered ? Appearance.colors.colLayer1Hover : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
            }

            ActiveWindow {
                visible: root.useShortenedForm === 0
                Layout.rightMargin: Appearance.rounding.screenRounding
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Row { // Middle section
        id: middleSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 4

        BarGroup {
            id: leftCenterGroup
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.centerSideModuleWidth

            PopoutWrapper {
                popoutId: "bar.resources"
                Layout.fillWidth: root.useShortenedForm === 2
                contentComponent: Component {
                    Resources {
                        alwaysShowAllResources: root.useShortenedForm === 2
                        Layout.fillWidth: root.useShortenedForm === 2
                    }
                }
            }

            PopoutWrapper {
                popoutId: "bar.media"
                visible: root.useShortenedForm < 2
                Layout.fillWidth: true
                contentComponent: Component {
                    Media {
                        visible: root.useShortenedForm < 2
                        Layout.fillWidth: true
                    }
                }
            }
        }

        VerticalBarSeparator {
            visible: Config.options?.bar.borderless
        }

        PopoutWrapper {
            popoutId: "bar.workspaces"
            contentComponent: Component {
                BarGroup {
                    id: middleCenterGroup
                    anchors.verticalCenter: parent.verticalCenter
                    padding: workspacesWidget.widgetPadding

                    Workspaces {
                        id: workspacesWidget
                        Layout.fillHeight: true
                        MouseArea {
                            // Right-click to toggle overview
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton

                            onPressed: event => {
                                if (event.button === Qt.RightButton) {
                                    GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
                                }
                            }
                        }
                    }
                }
            }
        }

        VerticalBarSeparator {
            visible: Config.options?.bar.borderless
        }

        PopoutWrapper {
            popoutId: "bar.clock"
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.centerSideModuleWidth
            contentComponent: Component {
                MouseArea {
                    id: rightCenterGroup
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: root.centerSideModuleWidth
                    implicitHeight: rightCenterGroupContent.implicitHeight

                    onPressed: {
                        if (root.reminderEditing)
                            root.cancelReminderEditing();
                        GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
                    }

                    BarGroup {
                        id: rightCenterGroupContent
                        anchors.fill: parent

                        ClockWidget {
                            showDate: (Config.options.bar.verbose && root.useShortenedForm < 2)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                        }

                        UtilButtons {
                            visible: (Config.options.bar.verbose && root.useShortenedForm === 0)
                            Layout.alignment: Qt.AlignVCenter
                        }

                        BatteryIndicator {
                            visible: (root.useShortenedForm < 2 && Battery.available)
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }

        VerticalBarSeparator {
            visible: Config.options?.bar.borderless
        }

        BarGroup {
            id: reminderGroup
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.centerSideModuleWidth
            padding: 6

            TextField {
                id: reminderField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Add reminder...")
                text: root.reminderDraft
                horizontalAlignment: Text.AlignHCenter
                selectByMouse: true
                inputMethodHints: Qt.ImhNoPredictiveText
                padding: 6
                color: activeFocus ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                renderType: Text.NativeRendering
                selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                selectionColor: Appearance.colors.colSecondaryContainer
                placeholderTextColor: Appearance.m3colors.m3outline
                background: null
                cursorVisible: root.reminderEditing && reminderField.activeFocus

                onActiveFocusChanged: {
                    if (activeFocus) {
                        root.reminderEditing = true;
                        root.reminderDraft = GlobalStates.barReminderText;
                        reminderField.selectAll();
                    } else if (root.reminderEditing) {
                        root.cancelReminderEditing();
                    }
                }

                onTextChanged: {
                    if (root.reminderEditing)
                        root.reminderDraft = text;
                }

                Keys.onReturnPressed: reminderField.commitReminderEditing(event);
                Keys.onEnterPressed: reminderField.commitReminderEditing(event);
                Keys.onEscapePressed: reminderField.cancelReminderEditing(event);
                onAccepted: reminderField.commitReminderEditing();

                function commitReminderEditing(event) {
                    if (!root.reminderEditing)
                        return;
                    root.reminderEditing = false;
                    GlobalStates.barReminderText = text;
                    root.reminderDraft = GlobalStates.barReminderText;
                    if (event)
                        event.accepted = true;
                    reminderField.focus = false;
                }

                function cancelReminderEditing(event) {
                    if (!root.reminderEditing)
                        return;
                    root.cancelReminderEditing();
                    if (event)
                        event.accepted = true;
                }
            }
        }
    }

    FocusedScrollMouseArea { // Right side | scroll to change volume
        id: barRightSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: middleSection.right
            right: parent.right
        }
        implicitWidth: rightSectionRowLayout.implicitWidth
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: Audio.decrementVolume();
        onScrollUp: Audio.incrementVolume();
        onMovedAway: GlobalStates.osdVolumeOpen = false;
        onPressed: event => {
            if (root.reminderEditing)
                root.cancelReminderEditing();
            if (event.button === Qt.LeftButton) {
                GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
            }
        }

        // Visual content
        ScrollHint {
            reveal: barRightSideMouseArea.hovered
            icon: "volume_up"
            tooltipText: Translation.tr("Scroll to change volume")
            side: "right"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: rightSectionRowLayout
            anchors.fill: parent
            spacing: 5
            layoutDirection: Qt.RightToLeft

            RippleButton { // Right sidebar button
                id: rightSidebarButton

                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Appearance.rounding.screenRounding
                Layout.fillWidth: false

                implicitWidth: indicatorsRowLayout.implicitWidth + 10 * 2
                implicitHeight: indicatorsRowLayout.implicitHeight + 5 * 2

                buttonRadius: Appearance.rounding.full
                colBackground: barRightSideMouseArea.hovered ? Appearance.colors.colLayer1Hover : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                colBackgroundHover: Appearance.colors.colLayer1Hover
                colRipple: Appearance.colors.colLayer1Active
                colBackgroundToggled: Appearance.colors.colSecondaryContainer
                colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
                colRippleToggled: Appearance.colors.colSecondaryContainerActive
                toggled: GlobalStates.sidebarRightOpen
                property color colText: toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0

                Behavior on colText {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                onPressed: {
                    GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
                }

                RowLayout {
                    id: indicatorsRowLayout
                    anchors.centerIn: parent
                    property real realSpacing: 15
                    spacing: 0

                    Revealer {
                        reveal: Audio.sink?.audio?.muted ?? false
                        Layout.fillHeight: true
                        Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                        Behavior on Layout.rightMargin {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        MaterialSymbol {
                            text: "volume_off"
                            iconSize: Appearance.font.pixelSize.larger
                            color: rightSidebarButton.colText
                        }
                    }
                    Revealer {
                        reveal: Audio.source?.audio?.muted ?? false
                        Layout.fillHeight: true
                        Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                        Behavior on Layout.rightMargin {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        MaterialSymbol {
                            text: "mic_off"
                            iconSize: Appearance.font.pixelSize.larger
                            color: rightSidebarButton.colText
                        }
                    }
                    HyprlandXkbIndicator {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: indicatorsRowLayout.realSpacing
                        color: rightSidebarButton.colText
                    }
                    Revealer {
                        reveal: Notifications.silent || Notifications.unread > 0
                        Layout.fillHeight: true
                        Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                        implicitHeight: reveal ? notificationUnreadCount.implicitHeight : 0
                        implicitWidth: reveal ? notificationUnreadCount.implicitWidth : 0
                        Behavior on Layout.rightMargin {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        NotificationUnreadCount {
                            id: notificationUnreadCount
                        }
                    }
                    MaterialSymbol {
                        text: Network.materialSymbol
                        iconSize: Appearance.font.pixelSize.larger
                        color: rightSidebarButton.colText
                    }
                    MaterialSymbol {
                        Layout.leftMargin: indicatorsRowLayout.realSpacing
                        visible: BluetoothStatus.available
                        text: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
                        iconSize: Appearance.font.pixelSize.larger
                        color: rightSidebarButton.colText
                    }
                }
            }

            SysTray {
                visible: root.useShortenedForm === 0
                Layout.fillWidth: false
                Layout.fillHeight: true
                invertSide: Config?.options.bar.bottom
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Weather
            Loader {
                Layout.leftMargin: 4
                active: Config.options.bar.weather.enable

                sourceComponent: BarGroup {
                    WeatherBar {}
                }
            }
        }
    }
}
