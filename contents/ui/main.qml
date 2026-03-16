import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.example.plasma.textwidget 1.0

PlasmoidItem {
    id: root

    TextProvider {
        id: textProvider
        filePath: Plasmoid.configuration.filePath
    }

    QQC2.ScrollView {
        anchors.fill: parent
        visible: textProvider.error.length === 0

        QQC2.TextArea {
            id: textArea
            text: textProvider.text
            readOnly: Plasmoid.configuration.readOnly
            wrapMode: Plasmoid.configuration.wordWrap ? TextEdit.Wrap : TextEdit.NoWrap
            font.family: "monospace"
            selectByMouse: true
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width * 0.9
        visible: textProvider.error.length > 0
        icon.name: "dialog-error"
        text: textProvider.error
    }
}