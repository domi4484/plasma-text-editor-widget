import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.syntaxhighlighting 1.0
import ch.customcut.plasma.textwidget 1.0

PlasmoidItem {
    id: root

    // Tracks the actual system color scheme (the one KDE apps like Kate use),
    // which is not always the same as the Plasma widget style Kirigami.Theme follows.
    SystemPalette {
        id: sysPalette
        colorGroup: SystemPalette.Active
    }
    readonly property bool isDarkTheme: Kirigami.ColorUtils.brightnessForColor(sysPalette.base) === Kirigami.ColorUtils.Dark

    TextProvider {
        id: textProvider
        filePath: Plasmoid.configuration.filePath
        watchFile: Plasmoid.configuration.watchFileChanges
        
        onFileChangedExternally: {
            reloadNotification.show()
        }
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
        theme: highlighter.repository ? highlighter.repository.defaultTheme(root.isDarkTheme ? Repository.DarkTheme : Repository.LightTheme) : null
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
                color: sysPalette.alternateBase

                QQC2.ScrollView {
                    anchors.fill: parent
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                    
                    QQC2.TextArea {
                        id: lineNumbersText
                        readOnly: true
                        font.family: textArea.font.family
                        font.pointSize: Plasmoid.configuration.fontSize
                        color: Qt.rgba(sysPalette.text.r, sysPalette.text.g, sysPalette.text.b, 0.6)
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
                    font.pointSize: Plasmoid.configuration.fontSize
                    selectByMouse: true
                    color: sysPalette.text
                    
                    // Current line highlight
                    Rectangle {
                        id: currentLineHighlight
                        visible: Plasmoid.configuration.highlightCurrentLine && textArea.activeFocus
                        color: Kirigami.Theme.highlightColor
                        opacity: 0.15
                        z: -1
                        
                        property int currentLine: {
                            var pos = textArea.cursorPosition
                            return textArea.text.substring(0, pos).split('\n').length - 1
                        }
                        
                        x: 0
                        width: textArea.contentWidth > textArea.width ? textArea.contentWidth : textArea.width
                        height: textArea.font.pixelSize * 1.3
                        
                        y: {
                            var line = currentLineHighlight.currentLine
                            return textArea.cursorRectangle.y
                        }
                    }
                    
                    // Ctrl + mouse wheel to zoom
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        
                        onWheel: (wheel) => {
                            if (wheel.modifiers & Qt.ControlModifier) {
                                var newSize = Plasmoid.configuration.fontSize + (wheel.angleDelta.y > 0 ? 1 : -1)
                                newSize = Math.max(6, Math.min(72, newSize))
                                Plasmoid.configuration.fontSize = newSize
                                wheel.accepted = true
                            } else {
                                wheel.accepted = false
                            }
                        }
                    }
                    
                    // Ctrl+Shift+Up/Down to move lines
                    Keys.onPressed: (event) => {
                        if ((event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                            if (event.key === Qt.Key_Up) {
                                moveLineUp()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                moveLineDown()
                                event.accepted = true
                            }
                        }
                    }
                    
                    function moveLineUp() {
                        if (readOnly) return
                        
                        var cursor = cursorPosition
                        var textBefore = text.substring(0, cursor)
                        var currentLine = textBefore.split('\n').length - 1
                        
                        if (currentLine === 0) return // Already at top
                        
                        var lines = text.split('\n')
                        
                        // Calculate cursor position within current line
                        var lineStartPos = textBefore.lastIndexOf('\n') + 1
                        var cursorInLine = cursor - lineStartPos
                        
                        // Swap current line with previous
                        var temp = lines[currentLine]
                        lines[currentLine] = lines[currentLine - 1]
                        lines[currentLine - 1] = temp
                        
                        text = lines.join('\n')
                        
                        // Calculate new cursor position
                        var newLineStartPos = 0
                        for (var i = 0; i < currentLine - 1; i++) {
                            newLineStartPos += lines[i].length + 1 // +1 for newline
                        }
                        cursorPosition = newLineStartPos + Math.min(cursorInLine, lines[currentLine - 1].length)
                    }
                    
                    function moveLineDown() {
                        if (readOnly) return
                        
                        var cursor = cursorPosition
                        var textBefore = text.substring(0, cursor)
                        var currentLine = textBefore.split('\n').length - 1
                        var lines = text.split('\n')
                        
                        if (currentLine === lines.length - 1) return // Already at bottom
                        
                        // Calculate cursor position within current line
                        var lineStartPos = textBefore.lastIndexOf('\n') + 1
                        var cursorInLine = cursor - lineStartPos
                        
                        // Swap current line with next
                        var temp = lines[currentLine]
                        lines[currentLine] = lines[currentLine + 1]
                        lines[currentLine + 1] = temp
                        
                        text = lines.join('\n')
                        
                        // Calculate new cursor position
                        var newLineStartPos = 0
                        for (var i = 0; i < currentLine + 1; i++) {
                            newLineStartPos += lines[i].length + 1 // +1 for newline
                        }
                        cursorPosition = newLineStartPos + Math.min(cursorInLine, lines[currentLine + 1].length)
                    }
                    
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

    // Reload notification when file changes externally
    Kirigami.InlineMessage {
        id: reloadNotification
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Kirigami.Units.smallSpacing
        type: Kirigami.MessageType.Information
        text: "File reloaded (changed externally)"
        visible: false
        
        function show() {
            visible = true
            hideReloadTimer.restart()
        }
        
        Timer {
            id: hideReloadTimer
            interval: 3000
            onTriggered: reloadNotification.visible = false
        }
    }
}
