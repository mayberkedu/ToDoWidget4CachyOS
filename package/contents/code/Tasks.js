.pragma library

// Date-only values deliberately use local calendar components, never UTC parsing.
function dateKey(date) {
    return String(date.getFullYear()).padStart(4, "0") + "-"
        + String(date.getMonth() + 1).padStart(2, "0") + "-"
        + String(date.getDate()).padStart(2, "0");
}

function parseDate(value) {
    if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value))
        return null;
    var parts = value.split("-").map(Number);
    if (parts[0] < 100 || parts[0] > 9999)
        return null;
    var date = new Date(parts[0], parts[1] - 1, parts[2], 12);
    return dateKey(date) === value ? date : null;
}

function validate(title, deadline, priority) {
    if (typeof title !== "string" || !title.trim())
        throw new Error("Task text cannot be empty.");
    if (title.trim().length > 240)
        throw new Error("Tasks can contain up to 240 characters.");
    if (deadline !== "" && !parseDate(deadline))
        throw new Error("Choose a valid deadline.");
    if (priority !== undefined && ["low", "medium", "high"].indexOf(priority) < 0)
        throw new Error("Choose a valid priority.");
}

function decode(raw) {
    try {
        var tasks = JSON.parse(raw);
        if (!Array.isArray(tasks))
            throw new Error("Invalid task list");
        var ids = Object.create(null);
        tasks = tasks.map(function(task) {
            if (!task || typeof task.id !== "string" || !task.id
                    || Object.prototype.hasOwnProperty.call(ids, task.id)
                    || typeof task.completed !== "boolean")
                throw new Error("Invalid task");
            validate(task.title, task.deadline, task.priority);
            ids[task.id] = true;
            // Older versions had no priority; keep those tasks and their order.
            return { id: task.id, title: task.title, deadline: task.deadline,
                completed: task.completed, priority: task.priority || "low" };
        });
        return { tasks: tasks, error: "" };
    } catch (error) {
        // Keep the saved value intact: the UI blocks writes until it can be read.
        return { tasks: [], error: "Saved tasks could not be read. Your data has not been overwritten." };
    }
}

function save(tasks, id, title, deadline, priority) {
    var existing = tasks.filter(function(task) { return task.id === id; })[0];
    priority = priority === undefined ? (existing ? existing.priority || "low" : "low") : priority;
    validate(title, deadline, priority);
    if (id) {
        return tasks.map(function(task) {
            return task.id === id
                ? { id: id, title: title.trim(), deadline: deadline, completed: task.completed, priority: priority }
                : task;
        });
    }
    var newId;
    do {
        newId = Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 10);
    } while (tasks.some(function(task) { return task.id === newId; }));
    return tasks.concat([{ id: newId, title: title.trim(), deadline: deadline, completed: false, priority: priority }]);
}

function toggle(tasks, id) {
    return tasks.map(function(task) {
        return task.id === id
            ? { id: task.id, title: task.title, deadline: task.deadline, completed: !task.completed, priority: task.priority || "low" }
            : task;
    });
}

function remove(tasks, id) {
    return tasks.filter(function(task) { return task.id !== id; });
}

function clearCompleted(tasks) {
    return tasks.filter(function(task) { return !task.completed; });
}

function setPriority(tasks, id, priority) {
    if (["low", "medium", "high"].indexOf(priority) < 0)
        throw new Error("Choose a valid priority.");
    return tasks.map(function(task) {
        return task.id === id
            ? { id: task.id, title: task.title, deadline: task.deadline, completed: task.completed, priority: priority }
            : task;
    });
}

function move(tasks, id, targetId) {
    var from = tasks.findIndex(function(task) { return task.id === id; });
    var to = tasks.findIndex(function(task) { return task.id === targetId; });
    if (from < 0 || to < 0 || from === to)
        return tasks;
    var result = tasks.slice();
    var task = result.splice(from, 1)[0];
    result.splice(to, 0, task);
    return result;
}

function priorityColor(priority) {
    return priority === "high" ? "#ff7c86" : priority === "medium" ? "#f8d779" : "#7be0ae";
}

function priorityLabel(priority, language) {
    if (language === "tr")
        return priority === "high" ? "Yüksek" : priority === "medium" ? "Orta" : "Düşük";
    return priority === "high" ? "High" : priority === "medium" ? "Medium" : "Low";
}

function filtered(tasks, filter) {
    return tasks.filter(function(task) {
        return filter === "all" || (filter === "done" ? task.completed : !task.completed);
    });
}

function deadlineLabel(deadline, now, language) {
    if (!deadline)
        return "";
    if (deadline === dateKey(now))
        return language === "tr" ? "Bugün" : "Today";
    var tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 12);
    if (deadline === dateKey(tomorrow))
        return language === "tr" ? "Yarın" : "Tomorrow";
    var date = parseDate(deadline);
    if (!date)
        return "";
    var months = language === "tr"
        ? ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
        : ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return date.getDate() + " " + months[date.getMonth()]
        + (date.getFullYear() !== now.getFullYear() ? " " + date.getFullYear() : "");
}
