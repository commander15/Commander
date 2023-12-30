#include "jsonlistmodel.h"

#include <QtQml/qjsvalueiterator.h>

JsonListModel::JsonListModel(QObject *parent) :
    QAbstractListModel(parent),
    m_rolesProperty(this, &m_roles),
    m_autoRoles(true),
    m_model(this)
{
}

QHash<int, QByteArray> JsonListModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    // If there is no predefined roles, get them from data
    if (m_autoRoles && m_roles.isEmpty() && m_data.property("length").toInt() > 0) {
        const QJSValue object = m_data.property(0);

        QJSValueIterator it(object);
        while (it.next()) {
            JsonListModelRole *role = new JsonListModelRole(m_model);
            role->setName(it.name());
            role->setPropertyName(it.name());
            m_model->m_roles.append(role);
        }
    }

    // Geting roles
    for (int i(0); i < m_roles.size(); ++i) {
        const JsonListModelRole *role = m_roles.at(i);
        roles.insert(i, role->name().toLatin1());
    }

    return roles;
}

QVariant JsonListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    const JsonListModelRole *modelRole = m_roles.at(role);
    const QJSValue object = m_data.property(index.row());

    if (object.hasOwnProperty(modelRole->propertyName())) {
        return object.property(modelRole->propertyName()).toVariant();
    } else if (!modelRole->aliases().isEmpty()) {
        const QStringList aliases = modelRole->aliases();
        for (const QString &alias : aliases)
            if (object.hasOwnProperty(alias))
                return object.property(alias).toVariant();
    }

    return modelRole->value();
}

int JsonListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_data.property("length").toInt();
}

QQmlListProperty<JsonListModelRole> JsonListModel::roles() const
{
    return m_rolesProperty;
}

QVariant JsonListModel::jsonData() const
{
    return QVariant::fromValue(m_data);
}

void JsonListModel::setJsonData(const QVariant &data)
{
    beginResetModel();

    m_data = data.value<QJSValue>();
    emit jsonDataChanged();

    //m_roles.clear();

    endResetModel();
}

JsonListModelRole::JsonListModelRole(QObject *parent) :
    QObject(parent)
{
}

QString JsonListModelRole::name() const
{
    return m_name;
}

void JsonListModelRole::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString JsonListModelRole::propertyName() const
{
    return m_property;
}

void JsonListModelRole::setPropertyName(const QString &name)
{
    if (m_property != name) {
        m_property = name;
        emit propertyNameChanged();
    }
}

QStringList JsonListModelRole::aliases() const
{
    return m_aliases;
}

void JsonListModelRole::setAliases(const QStringList &aliases)
{
    if (m_aliases != aliases) {
        m_aliases = aliases;
        emit aliasesChanged();
    }
}

QVariant JsonListModelRole::value() const
{
    return m_value;
}

void JsonListModelRole::setValue(const QVariant &value)
{
    if (m_value != value) {
        m_value = value;
        emit valueChanged();
    }
}
