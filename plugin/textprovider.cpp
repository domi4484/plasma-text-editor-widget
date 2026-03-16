#include "textprovider.h"

#include <QFile>
#include <QTextStream>

TextProvider::TextProvider(QObject *parent) : QObject(parent) {}

QString TextProvider::filePath() const { return m_filePath; }
QString TextProvider::text() const { return m_text; }
QString TextProvider::error() const { return m_error; }
bool TextProvider::canSave() const { return !m_filePath.isEmpty(); }

void TextProvider::setFilePath(const QString &path)
{
    if (m_filePath == path) {
        return;
    }
    m_filePath = path;
    emit filePathChanged();
    reload();
}

void TextProvider::saveFile(const QString &content)
{
    if (m_filePath.isEmpty()) {
        m_error = QStringLiteral("No file path configured for saving.");
        emit errorChanged();
        return;
    }

    QFile f(m_filePath);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        m_error = QStringLiteral("Cannot write to file: %1").arg(m_filePath);
        emit errorChanged();
        return;
    }

    QTextStream out(&f);
    out << content;
    f.close();

    // Update internal text to match saved content
    m_text = content;
    m_error.clear();
    
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