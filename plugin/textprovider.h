#pragma once

#include <QObject>
#include <QString>

class TextProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit TextProvider(QObject *parent = nullptr);

    QString filePath() const;
    QString text() const;
    QString error() const;

public slots:
    void setFilePath(const QString &path);

signals:
    void filePathChanged();
    void textChanged();
    void errorChanged();

private:
    void reload();

    QString m_filePath;
    QString m_text;
    QString m_error;
};