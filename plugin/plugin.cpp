#include <QQmlExtensionPlugin>
#include <qqml.h>

#include "textprovider.h"

class TextWidgetPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override
    {
        qmlRegisterType<TextProvider>(uri, 1, 0, "TextProvider");
    }
};

#include "plugin.moc"