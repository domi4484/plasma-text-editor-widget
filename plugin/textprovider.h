#pragma once

#include <QObject>
#include <QString>
#include <QFileSystemWatcher>

class TextProvider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(bool canSave READ canSave NOTIFY canSaveChanged)
    Q_PROPERTY(bool watchFile READ watchFile WRITE setWatchFile NOTIFY watchFileChanged)

public:
    explicit TextProvider(QObject *parent = nullptr);

    QString filePath() const;
    QString text() const;
    QString error() const;
    bool canSave() const;
    bool watchFile() const;

public slots:
    void setFilePath(const QString &path);
    void saveFile(const QString &content);
    void setWatchFile(bool watch);

signals:
    void filePathChanged();
    void textChanged();
    void errorChanged();
    void canSaveChanged();
    void fileSaved();
    void watchFileChanged();
    void fileChangedExternally();

private slots:
    void onFileChanged(const QString &path);

private:
    void reload();
    void updateWatcher();

    QString m_filePath;
    QString m_text;
    QString m_error;
    bool m_watchFile = true;
    QFileSystemWatcher *m_watcher = nullptr;
};