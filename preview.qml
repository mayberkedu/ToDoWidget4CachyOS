import QtQuick
import QtQuick.Controls
import "package/contents/ui"
import "package/contents/code/Tasks.js" as Tasks

ApplicationWindow {
    title: "Cachy To Do · Preview"
    visible: true
    width: 388
    height: 368
    minimumWidth: 328
    minimumHeight: 288
    color: "#17273e"

    TodoView {
        anchors.fill: parent
        anchors.margins: 24
        tasks: [
            { id: "demo-1", title: "Plan the week", deadline: Tasks.dateKey(new Date()), completed: false, priority: "high" },
            { id: "demo-2", title: "Make time for new ideas", deadline: "", completed: false, priority: "medium" },
            { id: "demo-3", title: "Organize the workspace", deadline: Tasks.dateKey(new Date(Date.now() + 86400000)), completed: false, priority: "low" },
            { id: "demo-4", title: "Start the day with coffee", deadline: "", completed: true }
        ]
        onTasksEdited: function(updatedTasks) { tasks = updatedTasks; }
    }
}
