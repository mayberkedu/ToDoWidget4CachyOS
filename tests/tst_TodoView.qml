import QtQuick
import QtQuick.Controls
import QtTest
import "../package/contents/ui"
import "../package/contents/code/Tasks.js" as Tasks

Item {
    width: 388
    height: 368

    ApplicationWindow {
        id: window
        width: 388
        height: 368
        visible: true
        color: "#17273e"

        TodoView {
            id: view
            anchors.fill: parent
            anchors.margins: 24
            onTasksEdited: function(updatedTasks) { tasks = updatedTasks; }
        }
        AppearanceControls {
            id: appearance
            anchors.fill: parent
            anchors.margins: 24
            visible: false
        }
    }

    TestCase {
        name: "TodoView"
        when: windowShown

        function init() {
            view.visible = true;
            appearance.visible = false;
            view.language = "en";
            appearance.language = "en";
            view.tasks = [];
            view.storageError = "";
            view.activeFilter = "all";
        }

        function cleanup() {
            findChild(window, "taskEditor").close();
            findChild(window, "taskContextMenu").close();
            view.visible = true;
            appearance.visible = false;
        }

        // Repeater/ListView delegates live in the visual tree, not necessarily
        // in the QObject parent tree traversed by QtTest.findChild().
        function visualItem(item, name) {
            if (item.objectName === name)
                return item;
            var children = item.children || [];
            for (var index = 0; index < children.length; ++index) {
                var found = visualItem(children[index], name);
                if (found)
                    return found;
            }
            return null;
        }

        function openViaContextMenu() {
            mouseClick(view, view.width - 20, view.height - 20, Qt.RightButton);
            var menu = findChild(window, "taskContextMenu");
            tryCompare(menu, "opened", true);
            mouseClick(findChild(window, "newTaskMenuItem"));
            tryCompare(menu, "opened", false);
        }

        function test_dragReordersAndPersists() {
            view.tasks = [
                { id: "a", title: "Birinci", deadline: "", completed: false, priority: "high" },
                { id: "b", title: "İkinci", deadline: "", completed: false, priority: "medium" },
                { id: "c", title: "Üçüncü", deadline: "", completed: false, priority: "low" }
            ];
            var list = findChild(window, "taskList");
            tryVerify(function() { return list.itemAtIndex(2) !== null; });
            var row = list.itemAtIndex(0);
            var start = row.mapToItem(window.contentItem, 120, row.height / 2);
            mousePress(window.contentItem, start.x, start.y);
            mouseMove(window.contentItem, start.x, start.y + 20, 40);
            tryCompare(view, "draggedId", "a");
            mouseMove(window.contentItem, start.x, start.y + 80, 40);
            mouseMove(window.contentItem, start.x, start.y + 140, 40);
            mouseRelease(window.contentItem, start.x, start.y + 140);
            tryCompare(view, "draggedId", "");
            compare(view.tasks[2].id, "a");
            compare(Tasks.decode(JSON.stringify(view.tasks)).tasks[2].id, "a");
            compare(view.tasks[2].priority, "high");

            tryVerify(function() { return list.itemAtIndex(2) !== null; });
            row = list.itemAtIndex(2);
            start = row.mapToItem(window.contentItem, 120, row.height / 2);
            mousePress(window.contentItem, start.x, start.y);
            mouseMove(window.contentItem, start.x, start.y - 20, 40);
            tryCompare(view, "draggedId", "a");
            mouseMove(window.contentItem, start.x, start.y - 80, 40);
            mouseMove(window.contentItem, start.x, start.y - 140, 40);
            mouseRelease(window.contentItem, start.x, start.y - 140);
            tryCompare(view, "draggedId", "");
            compare(view.tasks[0].id, "a");
        }

        function test_addEditCompleteAndFilter_data() {
            return [{ tag: "English", language: "en" }, { tag: "Turkish", language: "tr" }];
        }

        function test_addEditCompleteAndFilter(data) {
            view.language = data.language;
            openViaContextMenu();
            var editor = findChild(window, "taskEditor");
            tryCompare(editor, "opened", true);
            compare(findChild(window, "taskEditorTitle").text, data.language === "tr" ? "Yeni görev" : "New task");
            var title = findChild(window, "taskTitleField");
            title.text = "İlk görev";
            mouseClick(visualItem(editor.contentItem, "priority-high"));
            compare(editor.priority, "high");
            compare(visualItem(editor.contentItem, "priority-high").text, data.language === "tr" ? "Yüksek" : "High");
            mouseClick(findChild(window, "deadlineButton"));
            var today = findChild(window, "pickTodayButton");
            tryVerify(function() { return today.visible; });
            compare(today.text, data.language === "tr" ? "Bugün" : "Today");
            compare(findChild(window, "deadlineCalendar").locale.name, data.language === "tr" ? "tr_TR" : "en_US");
            mouseClick(today);
            compare(editor.deadline, Tasks.dateKey(new Date()));
            mouseClick(findChild(window, "saveTaskButton"));
            tryCompare(editor, "opened", false);
            compare(view.tasks.length, 1);
            compare(view.tasks[0].title, "İlk görev");
            compare(view.tasks[0].priority, "high");
            compare(view.tasks[0].deadline, Tasks.dateKey(new Date()));

            var check;
            tryVerify(function() {
                var row = findChild(window, "taskList").itemAtIndex(0);
                check = row ? findChild(row, "completion-" + view.tasks[0].id) : null;
                return check !== null;
            });
            mouseClick(check);
            compare(view.completedCount, 1);
            mouseClick(visualItem(window.contentItem, "filter-active"));
            compare(view.visibleTasks.length, 0);
            mouseClick(visualItem(window.contentItem, "filter-done"));
            compare(view.visibleTasks.length, 1);

            editor.show(view.tasks[0]);
            tryCompare(editor, "opened", true);
            title.text = "Düzenlenmiş görev";
            mouseClick(findChild(window, "saveTaskButton"));
            tryCompare(editor, "opened", false);
            compare(view.tasks[0].title, "Düzenlenmiş görev");
            verify(view.tasks[0].completed);
            compare(view.tasks[0].priority, "high");
        }

        function test_emptyTitleStaysOpen() {
            openViaContextMenu();
            var editor = findChild(window, "taskEditor");
            tryCompare(editor, "opened", true);
            mouseClick(findChild(window, "saveTaskButton"));
            verify(editor.opened);
            verify(editor.errorText.length > 0);
            compare(view.tasks.length, 0);
            editor.close();
            tryCompare(editor, "opened", false);
        }

        function test_appearanceSettingsAndPreview() {
            view.visible = false;
            appearance.visible = true;
            appearance.backgroundColor = "#bf4567";
            var tint = findChild(appearance, "tintStrengthSlider");
            waitForRendering(appearance);
            mouseClick(tint, tint.width - 1, tint.height / 2);
            compare(appearance.tintStrength, 100);
            var preview = findChild(appearance, "appearancePreview");
            compare(preview.tintColor, appearance.backgroundColor);
            compare(preview.mixedTint, appearance.backgroundColor);
            mouseClick(tint, 1, tint.height / 2);
            compare(appearance.tintStrength, 0);
            var neutral = preview.mixedTint;
            appearance.backgroundColor = "#0077ff";
            compare(preview.mixedTint, neutral);

            var opacity = findChild(appearance, "backgroundOpacitySlider");
            mouseClick(opacity, 1, opacity.height / 2);
            compare(appearance.backgroundOpacity, 0);
            compare(preview.effectiveOpacity, 0);
            mouseClick(opacity, opacity.width - 1, opacity.height / 2);
            compare(appearance.backgroundOpacity, 100);
            compare(preview.effectiveOpacity, 1);
            compare(preview.opacity, 1);
        }

        function test_configurationPageAliases() {
            var component = Qt.createComponent("../package/contents/ui/configAppearance.qml");
            compare(component.status, Component.Ready, component.errorString());
            var page = component.createObject(window.contentItem, {
                visible: false, cfg_language: "tr", cfg_backgroundColor: "#216648", cfg_tintStrength: 75, cfg_backgroundOpacity: 45
            });
            verify(page !== null);
            compare(page.cfg_backgroundColor, Qt.rgba(33 / 255, 102 / 255, 72 / 255, 1));
            compare(page.cfg_language, "tr");
            compare(findChild(page, "languageSelector").currentIndex, 1);
            compare(page.cfg_tintStrength, 75);
            compare(page.cfg_backgroundOpacity, 45);
            page.destroy();
        }

        function test_storageErrorDisablesEdits() {
            view.storageError = "Kayıt okunamadı";
            mouseClick(view, view.width - 20, view.height - 20, Qt.RightButton);
            var menu = findChild(window, "taskContextMenu");
            tryCompare(menu, "opened", true);
            verify(!findChild(window, "newTaskMenuItem").enabled);
            menu.close();
            tryCompare(menu, "opened", false);
            view.saveTask("", "Kaydedilmemeli", "", "low");
            compare(view.tasks.length, 0);
        }

        function test_renderAtMinimumSize() {
            window.width = 328;
            window.height = 288;
            view.tasks = Tasks.save([], "", "Uzun bir görev metni küçük widgetta da satıra sığmalı ve taşmamalı", "2027-10-22");
            waitForRendering(view);
            compare(view.width, 280);
            compare(findChild(window, "nyxLabel").text, "νύξ");
            compare(findChild(window, "nyxLabel").font.pixelSize, 16);
            verify(findChild(window, "addTaskButton") === null);
            window.width = 388;
            window.height = 368;
        }

        function test_liveLanguageSwitch() {
            view.tasks = Tasks.save([], "", "Türkçe görev metni", Tasks.dateKey(new Date()), "high");
            var saved = JSON.stringify(view.tasks);
            compare(visualItem(view, "filter-all").text, "All");
            var editor = findChild(window, "taskEditor");
            editor.show(null);
            tryCompare(editor, "opened", true);
            editor.submit();
            compare(findChild(window, "taskEditorError").text, "Task text cannot be empty.");
            view.language = "tr";
            compare(visualItem(view, "filter-all").text, "Tümü");
            compare(findChild(window, "taskEditorTitle").text, "Yeni görev");
            compare(findChild(window, "taskEditorError").text, "Görev metni boş olamaz.");
            compare(findChild(window, "saveTaskButton").text, "Görev ekle");
            view.language = "en";
            compare(visualItem(view, "filter-all").text, "All");
            compare(findChild(window, "saveTaskButton").text, "Add task");
            compare(JSON.stringify(view.tasks), saved);
        }

        function test_languageSelector() {
            view.visible = false;
            appearance.visible = true;
            var selector = findChild(appearance, "languageSelector");
            compare(selector.currentText, "English");
            waitForRendering(appearance);
            mouseClick(selector);
            tryCompare(selector.popup, "opened", true);
            var option = selector.popup.contentItem.itemAtIndex(1);
            verify(option !== null);
            mouseClick(option);
            tryCompare(selector.popup, "opened", false);
            compare(appearance.language, "tr");
            compare(findChild(appearance, "backgroundColorButton").Accessible.name, "Arka plan rengini seç");
        }

        function test_preview() {
            view.today = new Date(2026, 9, 22, 12);
            view.tasks = [
                { id: "1", title: "Plan the week", deadline: "2026-10-22", completed: false, priority: "high" },
                { id: "2", title: "Make time for new ideas", deadline: "", completed: false, priority: "medium" },
                { id: "3", title: "Organize the workspace", deadline: "2026-10-23", completed: false, priority: "low" },
                { id: "4", title: "Start the day with coffee", deadline: "", completed: true }
            ];
            waitForRendering(view);
            grabImage(window.contentItem).save("/tmp/cachy-todo-preview.png");
        }
    }
}
