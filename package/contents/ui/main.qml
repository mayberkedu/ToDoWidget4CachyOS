pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "../code/Tasks.js" as Tasks
import "../code/Strings.js" as Strings

PlasmoidItem {
    id: root
    signal newTaskRequested()

    // KConfig keys are supplied dynamically by contents/config/main.xml.
    // qmllint disable missing-property
    readonly property string language: Plasmoid.configuration.language || "en"
    readonly property var stored: Tasks.decode(Plasmoid.configuration.tasksJson)
    readonly property color configuredColor: Plasmoid.configuration.backgroundColor
    readonly property real configuredTint: Plasmoid.configuration.tintStrength / 100
    readonly property real configuredOpacity: Plasmoid.configuration.backgroundOpacity / 100
    // qmllint enable missing-property

    readonly property int remainingCount: stored.tasks.filter(function(task) { return !task.completed; }).length

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Layout.minimumWidth: 280
    Layout.minimumHeight: 240
    Layout.preferredWidth: 340
    Layout.preferredHeight: 320
    preferredRepresentation: fullRepresentation
    toolTipMainText: "Cachy To Do"
    toolTipSubText: Strings.text(root.language, remainingCount === 1 ? "1 task remaining" : "%1 tasks remaining", [remainingCount])

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: Strings.text(root.language, "New task")
            icon.name: "list-add"
            enabled: !root.stored.error
            onTriggered: root.newTaskRequested()
        }
    ]

    fullRepresentation: TodoView {
        id: todo
        language: root.language
        Layout.minimumWidth: 280
        Layout.minimumHeight: 240
        Layout.preferredWidth: 340
        Layout.preferredHeight: 320
        tasks: root.stored.tasks
        storageError: root.stored.error
        tintColor: root.configuredColor
        tintStrength: root.configuredTint
        backgroundOpacity: root.configuredOpacity
        onAppearanceRequested: Plasmoid.internalAction("configure").trigger()
        Connections {
            target: root
            function onNewTaskRequested(): void { todo.openNewTask(); }
        }
        onTasksEdited: function(updatedTasks) {
            if (!root.stored.error)
                // qmllint disable missing-property
                Plasmoid.configuration.tasksJson = JSON.stringify(updatedTasks);
                // qmllint enable missing-property
        }
    }
}
