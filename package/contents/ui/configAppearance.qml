import QtQuick
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_language: appearance.language
    property alias cfg_backgroundColor: appearance.backgroundColor
    property alias cfg_tintStrength: appearance.tintStrength
    property alias cfg_backgroundOpacity: appearance.backgroundOpacity

    AppearanceControls {
        id: appearance
    }
}
