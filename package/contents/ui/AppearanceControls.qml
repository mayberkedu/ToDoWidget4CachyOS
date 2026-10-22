import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts
import "../code/Strings.js" as Strings

ColumnLayout {
    id: appearance
    property string language: "en"

    property color backgroundColor: "#384459"
    property int tintStrength: 60
    property int backgroundOpacity: 65

    spacing: 18

    RowLayout {
        Layout.fillWidth: true
        Controls.Label { text: Strings.text(appearance.language, "Language"); Layout.fillWidth: true }
        Controls.ComboBox {
            objectName: "languageSelector"
            textRole: "label"
            valueRole: "code"
            model: [{ label: "English", code: "en" }, { label: "Türkçe", code: "tr" }]
            currentIndex: appearance.language === "tr" ? 1 : 0
            Accessible.name: Strings.text(appearance.language, "Language")
            onActivated: function(index) { appearance.language = model[index].code; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Controls.Label { text: Strings.text(appearance.language, "Glass color"); Layout.fillWidth: true }
        Controls.Button {
            id: colorButton
            objectName: "backgroundColorButton"
            text: appearance.backgroundColor.toString()
            Accessible.name: Strings.text(appearance.language, "Choose a background color")
            icon.name: "color-management"
            onClicked: {
                colorDialog.selectedColor = appearance.backgroundColor;
                colorDialog.open();
            }
            background: Rectangle {
                radius: 8
                color: appearance.backgroundColor
                border.width: colorButton.visualFocus ? 2 : 1
                border.color: colorButton.visualFocus ? "#bce0ff" : "#76869c"
            }
            contentItem: Text {
                text: colorButton.text
                color: (appearance.backgroundColor.r * 0.299 + appearance.backgroundColor.g * 0.587 + appearance.backgroundColor.b * 0.114) > 0.6 ? "#17202d" : "#ffffff"
                font: colorButton.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Controls.Label { text: Strings.text(appearance.language, "Tint / color blend"); Layout.fillWidth: true }
            Controls.Label { text: appearance.language === "tr" ? "%" + appearance.tintStrength : appearance.tintStrength + "%" }
        }
        Controls.Slider {
            objectName: "tintStrengthSlider"
            Layout.fillWidth: true
            from: 0
            to: 100
            stepSize: 1
            value: appearance.tintStrength
            Accessible.name: Strings.text(appearance.language, "Tint strength")
            onMoved: appearance.tintStrength = Math.round(value)
        }
        Controls.Label {
            Layout.fillWidth: true
            text: Strings.text(appearance.language, "0% neutral glass, 100% your chosen color.")
            font.pixelSize: 11
            opacity: 0.7
            wrapMode: Text.WordWrap
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Controls.Label { text: Strings.text(appearance.language, "Background opacity"); Layout.fillWidth: true }
            Controls.Label { text: appearance.language === "tr" ? "%" + appearance.backgroundOpacity : appearance.backgroundOpacity + "%" }
        }
        Controls.Slider {
            objectName: "backgroundOpacitySlider"
            Layout.fillWidth: true
            from: 0
            to: 100
            stepSize: 1
            value: appearance.backgroundOpacity
            Accessible.name: Strings.text(appearance.language, "Background opacity")
            onMoved: appearance.backgroundOpacity = Math.round(value)
        }
        Controls.Label {
            Layout.fillWidth: true
            text: Strings.text(appearance.language, "0% transparent, 100% opaque. Task text stays fully visible.")
            font.pixelSize: 11
            opacity: 0.7
            wrapMode: Text.WordWrap
        }
    }

    GlassSurface {
        id: preview
        objectName: "appearancePreview"
        Layout.fillWidth: true
        Layout.preferredHeight: 86
        tintColor: appearance.backgroundColor
        tintStrength: appearance.tintStrength / 100
        backgroundOpacity: appearance.backgroundOpacity / 100
        Text { anchors.centerIn: parent; text: "νύξ"; color: "#eff5ff"; font.pixelSize: 16; font.italic: true }
    }

    Dialogs.ColorDialog {
        id: colorDialog
        objectName: "backgroundColorDialog"
        title: Strings.text(appearance.language, "Choose a glass color")
        parentWindow: appearance.Window.window
        onAccepted: appearance.backgroundColor = selectedColor
    }
}
