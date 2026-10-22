import org.kde.plasma.plasmoid
import "../code/Strings.js" as Strings
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        // qmllint disable missing-property
        name: Strings.text(Plasmoid.configuration.language, "Appearance & language")
        // qmllint enable missing-property
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
}
