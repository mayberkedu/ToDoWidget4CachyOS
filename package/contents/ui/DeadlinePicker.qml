pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../code/Tasks.js" as Tasks
import "../code/Strings.js" as Strings

Controls.Popup {
    id: picker
    property string language: "en"

    property string selectedDate: ""
    property date displayedMonth: new Date()
    signal dateSelected(string value)

    width: Math.min(300, parent ? parent.width - 24 : 300)
    padding: 16
    modal: true
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside

    function show(value: string): void {
        selectedDate = value;
        displayedMonth = Tasks.parseDate(value) || new Date();
        open();
    }

    background: GlassSurface { raised: true; radius: 20 }

    contentItem: ColumnLayout {
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            ActionButton {
                text: "‹"
                Accessible.name: Strings.text(picker.language, "Previous month")
                onClicked: picker.displayedMonth = new Date(picker.displayedMonth.getFullYear(), picker.displayedMonth.getMonth() - 1, 1, 12)
            }
            Text {
                Layout.fillWidth: true
                text: calendar.title
                color: "#eeecf5"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }
            ActionButton {
                text: "›"
                Accessible.name: Strings.text(picker.language, "Next month")
                onClicked: picker.displayedMonth = new Date(picker.displayedMonth.getFullYear(), picker.displayedMonth.getMonth() + 1, 1, 12)
            }
        }

        Controls.DayOfWeekRow {
            Layout.fillWidth: true
            locale: calendar.locale
            delegate: Text {
                required property string narrowName
                text: narrowName
                color: "#9690a8"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Controls.MonthGrid {
            id: calendar
            objectName: "deadlineCalendar"
            Layout.fillWidth: true
            Layout.preferredHeight: 210
            month: picker.displayedMonth.getMonth()
            year: picker.displayedMonth.getFullYear()
            locale: Qt.locale(Strings.localeName(picker.language))
            delegate: Rectangle {
                required property var model
                readonly property bool chosen: Tasks.dateKey(model.date) === picker.selectedDate
                radius: 8
                color: chosen ? "#d5e9ff" : model.today ? "#30ffffff" : "transparent"
                opacity: model.month === calendar.month ? 1 : 0.3
                Text {
                    anchors.centerIn: parent
                    text: parent.model.day
                    color: parent.chosen ? "#1c172c" : "#eeecf5"
                    font.pixelSize: 13
                }
            }
            onClicked: function(date) {
                picker.dateSelected(Tasks.dateKey(date));
                picker.close();
            }
        }

        RowLayout {
            Layout.fillWidth: true
            ActionButton {
                objectName: "pickTodayButton"
                text: Strings.text(picker.language, "Today")
                Layout.fillWidth: true
                onClicked: { picker.dateSelected(Tasks.dateKey(new Date())); picker.close(); }
            }
            ActionButton {
                text: Strings.text(picker.language, "Clear date")
                Layout.fillWidth: true
                onClicked: { picker.dateSelected(""); picker.close(); }
            }
        }
    }
}
