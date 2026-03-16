#include "textprovider.h"

#include <QFile>
#include <QTextStream>

TextProvider::TextProvider(QObject *parent) : QObject(parent) {}

QString TextProvider::filePath() const { return m_filePath; }
QString TextProvider::text() const { return m_text; }
QString TextProvider::error() const { return m_error; }

void TextProvider::setFilePath(const QString &path)
{
    if (m_filePath == path) {
        return;
    }
    m_filePath = path;
    emit filePathChanged();
    reload();
}

void TextProvider::reload()
{
    m_text.clear();
    m_error.clear();

    if (m_filePath.isEmpty()) {
        m_error = QStringLiteral("No file configured.");
        emit errorChanged();
        emit textChanged();
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
}