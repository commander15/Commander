#ifndef COMMANDERURLINTERCEPTOR_H
#define COMMANDERURLINTERCEPTOR_H

#include <QtQml/qqmlabstracturlinterceptor.h>

class CommanderUrlInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    CommanderUrlInterceptor();

    bool canIntercept(const QUrl &path, DataType type) const;
    QUrl intercept(const QUrl &path, DataType type) override;

private:
    static QUrl m_baseUrl;
};

#endif // COMMANDERURLINTERCEPTOR_H
