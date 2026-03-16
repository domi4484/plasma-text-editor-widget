#pragma once

#include <QQuickPaintedItem>
#include <QPointer>
#include <QWidget>

#include <KTextEditor/Document>
#include <KTextEditor/View>
#include <KTextEditor/Editor>

class KTextEditorItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(bool readOnly READ readOnly WRITE setReadOnly NOTIFY readOnlyChanged)
    Q_PROPERTY(bool showLineNumbers READ showLineNumbers WRITE setShowLineNumbers NOTIFY showLineNumbersChanged)
    Q_PROPERTY(bool wordWrap READ wordWrap WRITE setWordWrap NOTIFY wordWrapChanged)
    Q_PROPERTY(QString syntaxMode READ syntaxMode WRITE setSyntaxMode NOTIFY syntaxModeChanged)

public:
    explicit KTextEditorItem(QQuickItem *parent = nullptr);
    ~KTextEditorItem() override;

    void paint(QPainter *painter) override;

    QString filePath() const { return m_filePath; }
    bool readOnly() const { return m_readOnly; }
    bool showLineNumbers() const { return m_showLineNumbers; }
    bool wordWrap() const { return m_wordWrap; }
    QString syntaxMode() const { return m_syntaxMode; }

public slots:
    void setFilePath(const QString &path);
    void setReadOnly(bool value);
    void setShowLineNumbers(bool value);
    void setWordWrap(bool value);
    void setSyntaxMode(const QString &mode);

signals:
    void filePathChanged();
    void readOnlyChanged();
    void showLineNumbersChanged();
    void wordWrapChanged();
    void syntaxModeChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    void ensureEditor();
    void applySettings();

    QString m_filePath;
    bool m_readOnly = true;
    bool m_showLineNumbers = true;
    bool m_wordWrap = false;
    QString m_syntaxMode = QStringLiteral("None");

    QPointer<KTextEditor::Document> m_doc;
    QPointer<KTextEditor::View> m_view;
    QWidget *m_container = nullptr;
};