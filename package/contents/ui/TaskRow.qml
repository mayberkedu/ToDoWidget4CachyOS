import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../code/Tasks.js" as Tasks
import "../code/Strings.js" as Strings

Item {
    id: row
    property string language: "en"
    required property var task
    property date today: new Date()
    property bool dropTarget: false
    property real scrollCompensation: 0
    readonly property bool dragging: drag.active
    readonly property bool overdue: !task.completed && task.deadline !== "" && task.deadline < Tasks.dateKey(today)
    readonly property color priorityColor: Tasks.priorityColor(task.priority || "low")
    signal toggled()
    signal editRequested()
    signal contextRequested(real x, real y)
    signal reorderStarted()
    signal reorderMoved(real offset)
    signal reorderFinished()

    implicitHeight: Math.max(48, title.implicitHeight + 22)
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: row.dropTarget ? "#385de3bb" : "transparent"
        border.color: row.dropTarget ? "#a7e0f2ff" : "transparent"
    }
    Rectangle {
        anchors.fill: parent
        radius: 12
        gradient: Gradient {
            GradientStop { position: 0; color: row.dragging ? "#f15a687e" : hover.hovered ? "#42697790" : "#2affffff" }
            GradientStop { position: 1; color: row.dragging ? "#f03e4a60" : hover.hovered ? "#32475971" : "#0dffffff" }
        }
        border.color: row.dragging ? "#a1e5efff" : hover.hovered ? "#72ffffff" : "#38ffffff"
        transform: Translate { y: drag.active ? drag.activeTranslation.y + row.scrollCompensation : 0 }
        scale: row.dragging ? 1.015 : 1
        Behavior on scale { NumberAnimation { duration: 120 } }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 7
            anchors.rightMargin: 5
            anchors.topMargin: 9
            anchors.bottomMargin: 9
            spacing: 7
            Controls.CheckBox {
                id: completion
                objectName: "completion-" + row.task.id
                implicitWidth: 24
                implicitHeight: 28
                padding: 3
                checked: row.task.completed
                Accessible.name: row.task.title + ": " + Strings.text(row.language, row.task.completed ? "Reopen" : "Complete")
                onClicked: row.toggled()
                indicator: Rectangle {
                    x: (completion.width - width) / 2
                    y: (completion.height - height) / 2
                    width: 18
                    height: 18
                    radius: 9
                    color: completion.checked ? row.priorityColor : "#12ffffff"
                    border.width: completion.visualFocus ? 2.5 : 1.5
                    border.color: row.priorityColor
                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        visible: completion.checked
                        color: "#20373a"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                background: Item {}
                Controls.ToolTip.visible: hovered
                Controls.ToolTip.text: Strings.text(row.language, "%1 priority", [Tasks.priorityLabel(row.task.priority || "low", row.language)])
            }
            Text {
                id: title
                Layout.fillWidth: true
                text: row.task.title
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: row.task.completed ? "#a8b6c9" : "#f5f8ff"
                font.pixelSize: 12
                font.strikeout: row.task.completed
                lineHeight: 1.2
                TapHandler { onDoubleTapped: row.editRequested() }
            }
            Rectangle {
                visible: row.task.deadline.length > 0
                implicitWidth: deadlineText.implicitWidth + 14
                implicitHeight: 22
                radius: 9
                color: row.overdue ? "#38ff788b" : "#1effffff"
                border.color: row.overdue ? "#40ffafb7" : "#20ffffff"
                Text {
                    id: deadlineText
                    anchors.centerIn: parent
                    text: Tasks.deadlineLabel(row.task.deadline, row.today, row.language)
                    color: row.overdue ? "#ffbdc4" : "#e2ebf8"
                    font.pixelSize: 10
                }
                HoverHandler { id: deadlineHover }
                Controls.ToolTip.visible: deadlineHover.hovered
                Controls.ToolTip.text: row.task.deadline + (row.overdue ? " · " + Strings.text(row.language, "Overdue") : "")
            }
            ActionButton {
                text: "⋮"
                implicitWidth: 24
                leftPadding: 2
                rightPadding: 2
                quiet: true
                Accessible.name: Strings.text(row.language, "Task options: %1", [row.task.title])
                onClicked: row.contextRequested(row.width - 24, row.height / 2)
            }
        }
    }
    HoverHandler { id: hover; cursorShape: row.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor }
    DragHandler {
        id: drag
        objectName: "drag-" + row.task.id
        target: null
        acceptedButtons: Qt.LeftButton
        xAxis.enabled: false
        onActiveChanged: {
            if (active)
                row.reorderStarted();
            else
                row.reorderFinished();
        }
        onActiveTranslationChanged: if (active) row.reorderMoved(activeTranslation.y)
    }
}
