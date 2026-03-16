import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: root

    property string fileContent: ""
    property string errorMessage: ""

    function loadFile() {
        var filePath = Plasmoid.configuration.filePath
        console.log("loadFile called, filePath:", filePath)
        if (!filePath || filePath.length === 0) {
            errorMessage = "No file configured."
            fileContent = ""
            console.log("No file path configured")
            return
        }

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                console.log("XHR status:", xhr.status, "statusText:", xhr.statusText)
                if (xhr.status === 200 || xhr.status === 0) {
                    fileContent = xhr.responseText
                    errorMessage = ""
                    console.log("File loaded successfully, length:", xhr.responseText.length)
                } else {
                    errorMessage = "Failed to load file: " + filePath
                    fileContent = ""
                    console.log("Failed to load file")
                }
            }
        }
        
        // Convert to file:// URL if not already
        var url = filePath
        if (!url.startsWith("file://") && !url.startsWith("http://") && !url.startsWith("https://")) {
            url = "file://" + filePath
        }
        
        console.log("Opening URL:", url)
        xhr.open("GET", url)
        xhr.send()
    }

    Component.onCompleted: {
        console.log("Component completed, initial config:", Plasmoid.configuration.filePath)
        loadFile()
    }

    Connections {
        target: Plasmoid.configuration
        function onFilePathChanged() {
            console.log("Config filePath changed to:", Plasmoid.configuration.filePath)
            loadFile()
        }
    }

    QQC2.ScrollView {
        anchors.fill: parent
        visible: errorMessage.length === 0

        QQC2.TextArea {
            id: textArea
            text: fileContent
            readOnly: Plasmoid.configuration.readOnly
            wrapMode: Plasmoid.configuration.wordWrap ? TextEdit.Wrap : TextEdit.NoWrap
            font.family: "monospace"
            selectByMouse: true
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width * 0.9
        visible: errorMessage.length > 0
        icon.name: "dialog-error"
        text: errorMessage
    }
}