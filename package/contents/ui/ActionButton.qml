import QtQuick
import QtQuick.Controls as Controls

Controls.Button {
    id: control

    property bool primary: false
    property bool selected: false
    property bool quiet: false
    property bool compact: false
    property color accent: "#d5e9ff"

    implicitHeight: compact ? 28 : 36
    implicitWidth: Math.max(28, contentItem.implicitWidth + (compact ? 16 : 24))
    leftPadding: compact ? 8 : 12
    rightPadding: compact ? 8 : 12
    hoverEnabled: true
    Accessible.name: text

    contentItem: Text {
        text: control.text
        font.pixelSize: control.compact ? 11 : 12
        font.weight: control.primary || control.selected ? Font.DemiBold : Font.Medium
        color: control.primary ? "#233249" : control.selected ? "#ffffff" : control.hovered ? "#ffffff" : "#c0cee0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 13
        color: control.primary ? (control.down ? "#adcbe9" : control.hovered ? "#eff7ff" : control.accent)
            : control.selected ? "#35ffffff" : control.down ? "#30ffffff" : control.hovered ? "#20ffffff" : control.quiet ? "transparent" : "#16ffffff"
        border.width: control.visualFocus ? 2 : 1
        border.color: control.visualFocus ? control.accent : control.selected ? "#55ffffff" : control.primary || control.quiet ? "transparent" : "#30ffffff"
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    opacity: enabled ? 1 : 0.4
    Controls.ToolTip.visible: hovered && Accessible.description.length > 0
    Controls.ToolTip.text: Accessible.description
}
