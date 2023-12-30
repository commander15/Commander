#ifndef JSONLISTMODEL_H
#define JSONLISTMODEL_H

#include <QtCore/qabstractitemmodel.h>

#include <QtQml/qqmlengine.h>

class JsonListModelRole;

class JsonListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<JsonListModelRole> roles READ roles)
    Q_PROPERTY(QVariant data READ jsonData WRITE setJsonData NOTIFY jsonDataChanged)
    QML_NAMED_ELEMENT(JsonListModelBase)
    QML_ADDED_IN_VERSION(1, 0)

public:
    explicit JsonListModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QQmlListProperty<JsonListModelRole> roles() const;

    QVariant jsonData() const;
    void setJsonData(const QVariant &data);
    Q_SIGNAL void jsonDataChanged();

private:
    QVector<JsonListModelRole *> m_roles;
    QQmlListProperty<JsonListModelRole> m_rolesProperty;
    bool m_autoRoles;

    QJSValue m_data;

    JsonListModel *m_model;
};

class JsonListModelRole : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString propertyName READ propertyName WRITE setPropertyName NOTIFY propertyNameChanged)
    Q_PROPERTY(QStringList aliases READ aliases WRITE setAliases NOTIFY aliasesChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)
    QML_NAMED_ELEMENT(JsonListModelRoleBase)
    QML_ADDED_IN_VERSION(1, 0)

public:
    JsonListModelRole(QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);
    Q_SIGNAL void nameChanged();

    QString propertyName() const;
    void setPropertyName(const QString &name);
    Q_SIGNAL void propertyNameChanged();

    QStringList aliases() const;
    void setAliases(const QStringList &aliases);
    Q_SIGNAL void aliasesChanged();

    QVariant value() const;
    void setValue(const QVariant &value);
    Q_SIGNAL void valueChanged();

private:
    QString m_name;
    QString m_property;
    QStringList m_aliases;
    QVariant m_value;
};

#endif // JSONLISTMODEL_H
