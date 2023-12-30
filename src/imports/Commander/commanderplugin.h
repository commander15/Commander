#ifndef COMMANDERPLUGIN_H
#define COMMANDERPLUGIN_H

#include <QtQml/qqmlextensionplugin.h>

class CommanderPlugin : public QQmlEngineExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.commander.qt")

public:
    explicit CommanderPlugin(QObject *parent = nullptr);
    ~CommanderPlugin();

public:
    void initializeEngine(QQmlEngine *engine, const char *uri) override;
};

#endif // COMMANDERPLUGIN_H
