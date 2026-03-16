import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_filePath: filePathField.text
    property alias cfg_syntaxMode: syntaxModeField.text
    property alias cfg_readOnly: readOnlyCheck.checked
    property alias cfg_showLineNumbers: lineNumbersCheck.checked
    property alias cfg_wordWrap: wordWrapCheck.checked

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

        QQC2.TextField {
            id: syntaxModeField
            Kirigami.FormData.label: "Syntax mode:"
            placeholderText: "None"
            enabled: false
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
            enabled: false
        }

        QQC2.CheckBox {
            id: wordWrapCheck
            Kirigami.FormData.label: "Word wrap:"
            text: "Enable wrapping"
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: "Note: Syntax highlighting and line numbers not yet implemented"
            wrapMode: Text.WordWrap
            opacity: 0.7
        }
    }
}