#include "ktexteditoritem.h"

#include <QPainter>
#include <QUrl>
#include <QWidget>
#include <QFileInfo>

#include <KTextEditor/Document>
#include <KTextEditor/Editor>
#include <KTextEditor/View>

KTextEditorItem::KTextEditorItem(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, true);
    ensureEditor();
}

KTextEditorItem::~KTextEditorItem()
{
    delete m_container;
    m_container = nullptr;
}

void KTextEditorItem::ensureEditor()
{
    if (m_view) {
        return;
    }

    auto *editor = KTextEditor::Editor::instance();
    if (!editor) {
        return;
    }

    m_doc = editor->createDocument(this);
    if (!m_doc) {
        return;
    }

    m_view = qobject_cast<KTextEditor::View *>(m_doc->createView(nullptr));
    if (!m_view) {
        return;
    }

    m_container = m_view;
    m_container->setAutoFillBackground(false);
    m_container->show();

    applySettings();
}

void KTextEditorItem::applySettings()
{
    if (!m_doc || !m_view) {
        return;
    }

    m_doc->setReadWrite(!m_readOnly);

    m_view->setConfigValue(QStringLiteral("line-numbers"), m_showLineNumbers);
    m_view->setConfigValue(QStringLiteral("dynamic-word-wrap"), m_wordWrap);

    if (!m_syntaxMode.isEmpty() && m_syntaxMode != QStringLiteral("None")) {
        m_doc->setHighlightingMode(m_syntaxMode);
    }

    if (!m_filePath.isEmpty()) {
        const QUrl url = QUrl::fromLocalFile(m_filePath);
        m_doc->openUrl(url);
    } else {
        m_doc->setText(QStringLiteral("No file configured."));
    }
}

void KTextEditorItem::paint(QPainter *painter)
{
    Q_UNUSED(painter)
    // Rendering is done by the QWidget-based KTextEditor::View.
}

void KTextEditorItem::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickPaintedItem::geometryChange(newGeometry, oldGeometry);

    if (m_container) {
        m_container->setGeometry(0, 0, int(newGeometry.width()), int(newGeometry.height()));
    }
}

void KTextEditorItem::setFilePath(const QString &path)
{
    if (m_filePath == path) {
        return;
    }

    m_filePath = path;
    emit filePathChanged();
    applySettings();
}

void KTextEditorItem::setReadOnly(bool value)
{
    if (m_readOnly == value) {
        return;
    }

    m_readOnly = value;
    emit readOnlyChanged();
    applySettings();
}

void KTextEditorItem::setShowLineNumbers(bool value)
{
    if (m_showLineNumbers == value) {
        return;
    }

    m_showLineNumbers = value;
    emit showLineNumbersChanged();
    applySettings();
}

void KTextEditorItem::setWordWrap(bool value)
{
    if (m_wordWrap == value) {
        return;
    }

    m_wordWrap = value;
    emit wordWrapChanged();
    applySettings();
}

void KTextEditorItem::setSyntaxMode(const QString &mode)
{
    if (m_syntaxMode == mode) {
        return;
    }

    m_syntaxMode = mode;
    emit syntaxModeChanged();
    applySettings();
}