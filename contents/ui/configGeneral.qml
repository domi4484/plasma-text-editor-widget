import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_filePath: filePathField.text
    property alias cfg_enableSyntaxHighlighting: syntaxHighlightingCheck.checked
    property alias cfg_readOnly: readOnlyCheck.checked
    property alias cfg_showLineNumbers: lineNumbersCheck.checked
    property alias cfg_wordWrap: wordWrapCheck.checked
    property alias cfg_watchFileChanges: watchFileChangesCheck.checked
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_highlightCurrentLine: highlightCurrentLineCheck.checked

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: "File path:"

            QQC2.TextField {
                id: filePathField
                Layout.fillWidth: true
                placeholderText: "/home/you/file.txt"
            }

            QQC2.Button {
                icon.name: "document-open"
                text: "Browse..."
                onClicked: fileDialog.open()
            }
        }

        FileDialog {
            id: fileDialog
            title: "Select text file"
            currentFolder: filePathField.text ? "file://" + filePathField.text.substring(0, filePathField.text.lastIndexOf("/")) : StandardPaths.writableLocation(StandardPaths.HomeLocation)
            onAccepted: {
                filePathField.text = selectedFile.toString().replace("file://", "")
            }
        }

        QQC2.CheckBox {
            id: syntaxHighlightingCheck
            Kirigami.FormData.label: "Syntax highlighting:"
            text: "Enable syntax highlighting"
        }

        QQC2.CheckBox {
            id: readOnlyCheck
            Kirigami.FormData.label: "Read-only:"
            text: "Prevent editing"
        }

        QQC2.CheckBox {
            id: lineNumbersCheck
            Kirigami.FormData.label: "Line numbers:"
            text: "Show line numbers"
        }

        QQC2.CheckBox {
            id: wordWrapCheck
            Kirigami.FormData.label: "Word wrap:"
            text: "Enable wrapping"
        }

        QQC2.CheckBox {
            id: watchFileChangesCheck
            Kirigami.FormData.label: "Auto-reload:"
            text: "Watch for external changes"
        }

        QQC2.SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: "Font size:"
            from: 6
            to: 72
            value: 10
            stepSize: 1
        }

        QQC2.CheckBox {
            id: highlightCurrentLineCheck
            Kirigami.FormData.label: "Current line:"
            text: "Highlight current line"
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: "Syntax highlighting auto-detects language from file extension.\nAuto-reload will refresh the content when the file changes on disk."
            wrapMode: Text.WordWrap
            opacity: 0.7
        }
    }
}
