pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../code/Tasks.js" as Tasks
import "../code/Strings.js" as Strings

Controls.Popup {
    id: editor
    property string language: "en"

    property string taskId: ""
    property string deadline: ""
    property string priority: "low"
    property string errorText: ""
    signal taskSaved(string taskId, string title, string deadline, string priority)

    width: Math.min(360, parent ? parent.width - 24 : 360)
    padding: 20
    modal: true
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside

    function show(task: var): void {
        taskId = task ? task.id : "";
        titleField.text = task ? task.title : "";
        deadline = task ? task.deadline : "";
        priority = task ? task.priority || "low" : "low";
        errorText = "";
        open();
        titleField.forceActiveFocus();
    }

    function submit(): void {
        try {
            Tasks.validate(titleField.text, deadline, priority);
            taskSaved(taskId, titleField.text, deadline, priority);
            close();
        } catch (error) {
            errorText = error.message;
        }
    }

    background: GlassSurface { raised: true; radius: 24 }

    contentItem: ColumnLayout {
        spacing: 16

        Text {
            objectName: "taskEditorTitle"
            text: Strings.text(editor.language, editor.taskId ? "Edit task" : "New task")
            color: "#f1eef8"
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
        Controls.TextField {
            id: titleField
            objectName: "taskTitleField"
            Layout.fillWidth: true
            implicitHeight: 46
            placeholderText: Strings.text(editor.language, "Task text")
            placeholderTextColor: "#888297"
            color: "#f1eef8"
            selectionColor: "#526e92"
            selectedTextColor: "#ffffff"
            font.pixelSize: 14
            maximumLength: 240
            leftPadding: 12
            rightPadding: 12
            Accessible.name: Strings.text(editor.language, "Task text")
            background: Rectangle {
                radius: 10
                color: "#350c172b"
                border.color: titleField.activeFocus ? "#c5e4ff" : "#38ffffff"
            }
            onAccepted: editor.submit()
        }
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: Strings.text(editor.language, "Deadline")
                color: "#b6b0c5"
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            ActionButton {
                objectName: "deadlineButton"
                text: editor.deadline ? Tasks.parseDate(editor.deadline).toLocaleDateString(Qt.locale(Strings.localeName(editor.language)), "d MMM yyyy") : Strings.text(editor.language, "Choose date · optional")
                Accessible.name: Strings.text(editor.language, "Choose a deadline")
                onClicked: calendar.show(editor.deadline)
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { text: Strings.text(editor.language, "Priority"); color: "#cbd6e6"; font.pixelSize: 12 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Repeater {
                    model: ["low", "medium", "high"]
                    Controls.Button {
                        id: priorityButton
                        required property string modelData
                        objectName: "priority-" + modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        implicitHeight: 38
                        padding: 8
                        topInset: 0
                        bottomInset: 0
                        leftInset: 0
                        rightInset: 0
                        text: Tasks.priorityLabel(modelData, editor.language)
                        Accessible.name: Strings.text(editor.language, "%1 priority", [text])
                        checkable: true
                        checked: editor.priority === modelData
                        onClicked: editor.priority = modelData
                        background: Rectangle {
                            radius: 12
                            color: priorityButton.checked ? "#26ffffff" : "#0cffffff"
                            border.color: priorityButton.checked ? Tasks.priorityColor(priorityButton.modelData) : "#28ffffff"
                        }
                        contentItem: Item {
                            implicitWidth: priorityContent.implicitWidth
                            implicitHeight: priorityContent.implicitHeight
                            RowLayout {
                                id: priorityContent
                                anchors.centerIn: parent
                                spacing: 6
                                Rectangle {
                                    Layout.alignment: Qt.AlignVCenter
                                    implicitWidth: 7
                                    implicitHeight: 7
                                    radius: 4
                                    color: Tasks.priorityColor(priorityButton.modelData)
                                }
                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: priorityButton.text
                                    color: "#f1f6ff"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            visible: editor.errorText.length > 0
            objectName: "taskEditorError"
            text: Strings.text(editor.language, editor.errorText)
            wrapMode: Text.WordWrap
            color: "#f1a0ab"
            font.pixelSize: 12
        }
        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            ActionButton { text: Strings.text(editor.language, "Cancel"); quiet: true; onClicked: editor.close() }
            ActionButton {
                objectName: "saveTaskButton"
                text: Strings.text(editor.language, editor.taskId ? "Save" : "Add task")
                primary: true
                onClicked: editor.submit()
            }
        }
    }

    DeadlinePicker {
        id: calendar
        language: editor.language
        parent: Controls.Overlay.overlay
        anchors.centerIn: parent
        onDateSelected: function(value) { editor.deadline = value; }
    }
}
