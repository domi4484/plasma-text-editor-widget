#include "textprovider.h"

#include <QFile>
#include <QTextStream>

TextProvider::TextProvider(QObject *parent) : QObject(parent)
{
    m_watcher = new QFileSystemWatcher(this);
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &TextProvider::onFileChanged);
}

QString TextProvider::filePath() const { return m_filePath; }
QString TextProvider::text() const { return m_text; }
QString TextProvider::error() const { return m_error; }
bool TextProvider::canSave() const { return !m_filePath.isEmpty(); }
bool TextProvider::watchFile() const { return m_watchFile; }

void TextProvider::setFilePath(const QString &path)
{
    if (m_filePath == path) {
        return;
    }
    m_filePath = path;
    emit filePathChanged();
    updateWatcher();
    reload();
}

void TextProvider::setWatchFile(bool watch)
{
    if (m_watchFile == watch) {
        return;
    }
    m_watchFile = watch;
    emit watchFileChanged();
    updateWatcher();
}

void TextProvider::onFileChanged(const QString &path)
{
    Q_UNUSED(path)
    
    // File was modified externally, reload it
    reload();
    emit fileChangedExternally();
    
    // Re-add to watcher (some editors remove and recreate files on save)
    if (m_watchFile && !m_filePath.isEmpty()) {
        if (!m_watcher->files().contains(m_filePath)) {
            m_watcher->addPath(m_filePath);
        }
    }
}

void TextProvider::updateWatcher()
{
    // Remove all watched files
    if (!m_watcher->files().isEmpty()) {
        m_watcher->removePaths(m_watcher->files());
    }
    
    // Add current file if watching is enabled
    if (m_watchFile && !m_filePath.isEmpty() && QFile::exists(m_filePath)) {
        m_watcher->addPath(m_filePath);
    }
}

void TextProvider::saveFile(const QString &content)
{
    if (m_filePath.isEmpty()) {
        m_error = QStringLiteral("No file path configured for saving.");
        emit errorChanged();
        return;
    }

    // Temporarily remove file from watcher to avoid triggering on our own save
    bool wasWatching = false;
    if (m_watchFile && m_watcher->files().contains(m_filePath)) {
        m_watcher->removePath(m_filePath);
        wasWatching = true;
    }

    QFile f(m_filePath);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        m_error = QStringLiteral("Cannot write to file: %1").arg(m_filePath);
        emit errorChanged();
        
        // Re-add to watcher if it was being watched
        if (wasWatching) {
            m_watcher->addPath(m_filePath);
        }
        return;
    }

    QTextStream out(&f);
    out << content;
    f.close();

    // Update internal text to match saved content
    m_text = content;
    m_error.clear();
    
    // Re-add to watcher if it was being watched
    if (wasWatching) {
        m_watcher->addPath(m_filePath);
    }
    
    emit textChanged();
    emit errorChanged();
    emit fileSaved();
}

void TextProvider::reload()
{
    m_text.clear();
    m_error.clear();

    if (m_filePath.isEmpty()) {
        m_error = QStringLiteral("No file configured.");
        emit errorChanged();
        emit textChanged();
        emit canSaveChanged();
        return;
    }

    QFile f(m_filePath);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_error = QStringLiteral("Cannot open file: %1").arg(m_filePath);
        emit errorChanged();
        emit textChanged();
        return;
    }

    QTextStream in(&f);
    m_text = in.readAll();

    emit errorChanged();
    emit textChanged();
    emit canSaveChanged();
}