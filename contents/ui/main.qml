import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.syntaxhighlighting 1.0
import org.example.plasma.textwidget 1.0

PlasmoidItem {
    id: root

    TextProvider {
        id: textProvider
        filePath: Plasmoid.configuration.filePath
    }

    // Auto-save timer - triggers 1.5 seconds after last edit
    Timer {
        id: saveTimer
        interval: 1500
        repeat: false
        onTriggered: {
            if (!Plasmoid.configuration.readOnly && textArea.text !== textProvider.text) {
                textProvider.saveFile(textArea.text)
            }
        }
    }

    // Syntax highlighter - auto-detect from file extension
    SyntaxHighlighter {
        id: highlighter
        textEdit: textArea
        definition: {
            if (!Plasmoid.configuration.enableSyntaxHighlighting) {
                return ""
            }
            
            var path = textProvider.filePath
            if (!path) return ""
            
            // Extract file extension
            var ext = path.substring(path.lastIndexOf(".") + 1).toLowerCase()
            
            // Map common extensions to syntax definitions
            var syntaxMap = {
                "cpp": "C++",
                "cc": "C++",
                "cxx": "C++",
                "h": "C++",
                "hpp": "C++",
                "c": "C",
                "py": "Python",
                "js": "JavaScript",
                "json": "JSON",
                "xml": "XML",
                "html": "HTML",
                "css": "CSS",
                "sh": "Bash",
                "bash": "Bash",
                "zsh": "Zsh",
                "md": "Markdown",
                "txt": "None",
                "cmake": "CMake",
                "qml": "QML",
                "java": "Java",
                "rs": "Rust",
                "go": "Go",
                "yaml": "YAML",
                "yml": "YAML",
                "toml": "TOML",
                "ini": "INI",
                "conf": "INI"
            }
            
            return syntaxMap[ext] || "None"
        }
        theme: highlighter.repository ? highlighter.repository.defaultTheme(Kirigami.Theme.colorSet === Kirigami.Theme.View ? 1 : 2) : null
    }

    Item {
        anchors.fill: parent
        visible: textProvider.error.length === 0

        Row {
            anchors.fill: parent
            spacing: 0

            // Line numbers column
            Rectangle {
                id: lineNumbersColumn
                width: visible ? lineNumbersText.implicitWidth + Kirigami.Units.smallSpacing * 2 : 0
                height: parent.height
                visible: Plasmoid.configuration.showLineNumbers
                color: Kirigami.Theme.alternateBackgroundColor

                QQC2.ScrollView {
                    anchors.fill: parent
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    
                    QQC2.TextArea {
                        id: lineNumbersText
                        readOnly: true
                        font.family: textArea.font.family
                        font.pointSize: textArea.font.pointSize
                        color: Kirigami.Theme.disabledTextColor
                        background: null
                        selectByMouse: false
                        padding: Kirigami.Units.smallSpacing
                        rightPadding: Kirigami.Units.smallSpacing
                        
                        // Generate line numbers based on main text area
                        text: {
                            var lines = textArea.lineCount
                            var result = ""
                            for (var i = 1; i <= lines; i++) {
                                result += i + "\n"
                            }
                            return result
                        }
                        
                        // Sync scrolling with main text area
                        Connections {
                            target: textArea.flickableItem
                            function onContentYChanged() {
                                lineNumbersText.flickableItem.contentY = textArea.flickableItem.contentY
                            }
                        }
                    }
                }
            }

            // Main text editor
            QQC2.ScrollView {
                width: parent.width - lineNumbersColumn.width
                height: parent.height

                QQC2.TextArea {
                    id: textArea
                    text: textProvider.text
                    readOnly: Plasmoid.configuration.readOnly
                    wrapMode: Plasmoid.configuration.wordWrap ? TextEdit.Wrap : TextEdit.NoWrap
                    font.family: "monospace"
                    selectByMouse: true
                    color: Kirigami.Theme.textColor
                    
                    // Trigger auto-save timer on text change
                    onTextChanged: {
                        if (!readOnly && text !== textProvider.text) {
                            saveTimer.restart()
                        }
                    }
                    

                    
                    // Reload when provider updates
                    Connections {
                        target: textProvider
                        function onTextChanged() {
                            if (textArea.text !== textProvider.text) {
                                textArea.text = textProvider.text
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Show save indicator when file is saved
    Connections {
        target: textProvider
        function onFileSaved() {
            saveIndicator.show()
        }
    }

    // Save indicator
    QQC2.Label {
        id: saveIndicator
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Kirigami.Units.smallSpacing
        text: "Saved ✓"
        opacity: 0
        visible: !Plasmoid.configuration.readOnly
        
        function show() {
            opacity = 1
            hideTimer.restart()
        }
        
        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: saveIndicator.opacity = 0
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
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