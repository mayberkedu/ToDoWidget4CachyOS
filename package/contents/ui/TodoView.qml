pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../code/Tasks.js" as Tasks
import "../code/Strings.js" as Strings

GlassSurface {
    id: view
    property string language: "en"
    property var tasks: []
    property string storageError: ""
    property string activeFilter: "all"
    property date today: new Date()
    property string contextTaskId: ""
    property string draggedId: ""
    property int dropIndex: -1
    property real dragPointerY: 0
    property real dragOriginContentY: 0
    readonly property int completedCount: tasks.filter(function(task) { return task.completed; }).length
    readonly property var visibleTasks: Tasks.filtered(tasks, activeFilter)
    readonly property var contextTask: tasks.filter(function(task) { return task.id === view.contextTaskId; })[0] || null
    signal tasksEdited(var updatedTasks)
    signal appearanceRequested()

    implicitWidth: 340
    implicitHeight: 320

    function openNewTask(): void {
        if (!storageError)
            editor.show(null);
    }

    function saveTask(id: string, title: string, deadline: string, priority: string): void {
        if (!storageError)
            tasksEdited(Tasks.save(tasks, id, title, deadline, priority));
    }

    function updateDrop(pointerY: real): void {
        dragPointerY = pointerY;
        var closest = Infinity;
        dropIndex = -1;
        for (var index = 0; index < visibleTasks.length; ++index) {
            var item = taskList.itemAtIndex(index);
            if (!item)
                continue;
            var distance = Math.abs(item.y + item.height / 2 - taskList.contentY - pointerY);
            if (distance < closest) {
                closest = distance;
                dropIndex = index;
            }
        }
    }

    function finishDrag(): void {
        var target = dropIndex >= 0 ? visibleTasks[dropIndex] : null;
        var source = draggedId;
        draggedId = "";
        dropIndex = -1;
        if (target && !storageError)
            tasksEdited(Tasks.move(tasks, source, target.id));
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: view.today = new Date()
    }
    Timer {
        interval: 24
        repeat: true
        running: view.draggedId !== ""
        onTriggered: {
            var step = view.dragPointerY < 32 ? -7 : view.dragPointerY > taskList.height - 32 ? 7 : 0;
            if (step) {
                taskList.contentY = Math.max(0, Math.min(Math.max(0, taskList.contentHeight - taskList.height), taskList.contentY + step));
                view.updateDrop(view.dragPointerY);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 9
        RowLayout {
            Layout.fillWidth: true
            spacing: 2
            Repeater {
                model: [{ key: "all", label: "All" }, { key: "active", label: "To do" }, { key: "done", label: "Done" }]
                ActionButton {
                    required property var modelData
                    objectName: "filter-" + modelData.key
                    text: Strings.text(view.language, modelData.label)
                    quiet: true
                    compact: true
                    selected: view.activeFilter === modelData.key
                    onClicked: view.activeFilter = modelData.key
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                objectName: "nyxLabel"
                text: "νύξ"
                color: "#eff5ff"
                font.pixelSize: 16
                font.italic: true
                font.letterSpacing: 0.5
                rightPadding: 4
            }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#21ffffff" }
        Text {
            Layout.fillWidth: true
            visible: view.storageError !== ""
            text: Strings.text(view.language, view.storageError)
            textFormat: Text.PlainText
            color: "#ffb0b6"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
            ListView {
                id: taskList
                objectName: "taskList"
                spacing: 6
                model: view.visibleTasks
                boundsBehavior: Flickable.StopAtBounds
                interactive: view.draggedId === ""
                // Keep the source delegate alive while auto-scrolling a long list.
                cacheBuffer: view.draggedId !== "" ? contentHeight : height
                delegate: TaskRow {
                    id: taskRow
                    required property var modelData
                    required property int index
                    width: taskList.width - 9
                    task: modelData
                    today: view.today
                    language: view.language
                    dropTarget: view.draggedId !== "" && view.draggedId !== task.id && view.dropIndex === index
                    enabled: !view.storageError
                    scrollCompensation: dragging ? taskList.contentY - view.dragOriginContentY : 0
                    z: dragging ? 10 : 0
                    onToggled: view.tasksEdited(Tasks.toggle(view.tasks, modelData.id))
                    onEditRequested: editor.show(modelData)
                    onContextRequested: function(x, y) {
                        view.contextTaskId = task.id;
                        var point = taskRow.mapToItem(view, x, y);
                        contextMenu.popup(point.x, point.y);
                    }
                    onReorderStarted: {
                        view.dragOriginContentY = taskList.contentY;
                        view.draggedId = task.id;
                    }
                    onReorderMoved: function(offset) { view.updateDrop(taskRow.y + height / 2 - view.dragOriginContentY + offset); }
                    onReorderFinished: view.finishDrag()
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width - 24
                    visible: view.visibleTasks.length === 0 && !view.storageError
                    text: Strings.text(view.language, view.tasks.length === 0 ? "Right-click to add a task" : "No tasks in this view")
                    color: "#b8c4da"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Left clicks pass through this area to controls and drag handlers.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        z: 100
        onClicked: function(mouse) {
            var point = taskList.mapFromItem(view, mouse.x, mouse.y);
            var index = point.x >= 0 && point.x <= taskList.width && point.y >= 0 && point.y <= taskList.height
                ? taskList.indexAt(point.x, point.y + taskList.contentY) : -1;
            view.contextTaskId = index >= 0 ? view.visibleTasks[index].id : "";
            contextMenu.popup(mouse.x, mouse.y);
        }
    }
    Controls.Menu {
        id: contextMenu
        objectName: "taskContextMenu"
        Controls.MenuItem {
            objectName: "newTaskMenuItem"
            text: Strings.text(view.language, "New task")
            enabled: !view.storageError
            onTriggered: view.openNewTask()
        }
        Controls.MenuSeparator { visible: view.contextTask !== null }
        Controls.MenuItem {
            text: Strings.text(view.language, "Edit")
            visible: view.contextTask !== null
            onTriggered: editor.show(view.contextTask)
        }
        Controls.Menu {
            title: Strings.text(view.language, "Priority")
            visible: view.contextTask !== null
            Repeater {
                model: ["low", "medium", "high"]
                Controls.MenuItem {
                    required property string modelData
                    text: Tasks.priorityLabel(modelData, view.language) + " · " + Strings.text(view.language, modelData === "low" ? "Green" : modelData === "medium" ? "Yellow" : "Red")
                    checkable: true
                    checked: view.contextTask !== null && view.contextTask.priority === modelData
                    onTriggered: view.tasksEdited(Tasks.setPriority(view.tasks, view.contextTaskId, modelData))
                }
            }
        }
        Controls.MenuItem {
            text: Strings.text(view.language, "Delete")
            visible: view.contextTask !== null
            onTriggered: view.tasksEdited(Tasks.remove(view.tasks, view.contextTaskId))
        }
        Controls.MenuSeparator { visible: view.completedCount > 0 }
        Controls.MenuItem {
            text: Strings.text(view.language, "Clear completed")
            visible: view.completedCount > 0
            enabled: !view.storageError
            onTriggered: view.tasksEdited(Tasks.clearCompleted(view.tasks))
        }
        Controls.MenuSeparator {}
        Controls.MenuItem {
            objectName: "appearanceMenuItem"
            text: Strings.text(view.language, "Appearance & language…")
            onTriggered: view.appearanceRequested()
        }
    }
    TaskEditor {
        id: editor
        objectName: "taskEditor"
        language: view.language
        parent: Controls.Overlay.overlay
        anchors.centerIn: parent
        onTaskSaved: function(id, title, deadline, priority) { view.saveTask(id, title, deadline, priority); }
    }
    Shortcut {
        sequence: "Ctrl+N"
        enabled: view.visible && view.enabled && !view.storageError && !editor.opened
        onActivated: view.openNewTask()
    }
}
