import QtQuick

Rectangle {
    id: glass
    property bool raised: false
    property color tintColor: "#384459"
    property real tintStrength: 0.6
    property real backgroundOpacity: 0.65
    readonly property real effectiveOpacity: raised ? Math.max(0.94, backgroundOpacity) : Math.max(0, Math.min(1, backgroundOpacity))
    readonly property color mixedTint: Qt.rgba(
        0.16 + (tintColor.r - 0.16) * Math.max(0, Math.min(1, tintStrength)),
        0.17 + (tintColor.g - 0.17) * Math.max(0, Math.min(1, tintStrength)),
        0.19 + (tintColor.b - 0.19) * Math.max(0, Math.min(1, tintStrength)), 1)

    function surfaceColor(lightness: real): color {
        return Qt.rgba(Math.min(1, mixedTint.r + lightness), Math.min(1, mixedTint.g + lightness),
            Math.min(1, mixedTint.b + lightness), effectiveOpacity);
    }

    radius: 21
    gradient: Gradient {
        GradientStop { position: 0; color: glass.surfaceColor(0.08) }
        GradientStop { position: 0.45; color: glass.surfaceColor(0) }
        GradientStop { position: 1; color: glass.surfaceColor(0.025) }
    }
    border.width: 1
    border.color: "#55eff6ff"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, glass.radius - 1)
        color: "transparent"
        border.color: "#18ffffff"
    }
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 1
        width: parent.width - glass.radius * 2
        height: 1
        color: "#85ffffff"
        opacity: 0.6
    }
}
