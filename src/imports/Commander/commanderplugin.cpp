#include "commanderplugin.h"

#include "commanderurlinterceptor.h"
#include "image/imageprovider.h"

#include <QtQml/qqmlengine.h>

extern void qml_register_types_Commander();

CommanderPlugin::CommanderPlugin(QObject *parent) :
    QQmlEngineExtensionPlugin(parent)
{
    volatile auto registration = &qml_register_types_Commander;
    Q_UNUSED(registration)
}

CommanderPlugin::~CommanderPlugin()
{
}

void CommanderPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    engine->addUrlInterceptor(new CommanderUrlInterceptor);
    engine->addImageProvider("commander_image", new ImageProvider);
}
