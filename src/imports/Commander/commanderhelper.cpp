#include "commanderhelper.h"

#include <QtGui/QGuiApplication>
#include <QtGui/QScreen>

#include <QtCore/qfile.h>
#include <QtCore/qstandardpaths.h>

CommanderHelper::CommanderHelper(QObject *parent) :
    QObject(parent),
    m_devDpi(96)
{
}

CommanderHelper::~CommanderHelper()
{
}

QString CommanderHelper::appVersion() const
{
    return qApp->applicationVersion();
}

void CommanderHelper::init(QQuickWindow *win)
{
    if (win->icon().isNull())
        win->setIcon(QIcon(":/qt/qml/Commander/icons/commander_logo.png"));
}

int CommanderHelper::sp(int size)
{
    return dp(size * 1.1);
}

int CommanderHelper::dp(int size)
{
    double dpi = qApp->primaryScreen()->physicalDotsPerInch();
    return size * (m_devDpi / dpi);
}

double CommanderHelper::devDpi() const
{
    return m_devDpi;
}

void CommanderHelper::setDevDpi(double dpi)
{
    if (m_devDpi == dpi)
        return;

    m_devDpi = dpi;
    emit devDpiChanged();
}

QUrl CommanderHelper::fileUrl(const QString &fileName)
{
    return QUrl::fromLocalFile(this->fileName(fileName));
}

QString CommanderHelper::readFile(const QString &fileName)
{
    QFile file(this->fileName(fileName));
    if (file.open(QIODevice::ReadOnly))
        return file.readAll();
    else
        return QString();
}

bool CommanderHelper::writeFile(const QString &fileName, const QString &data)
{
    QFile file(this->fileName(fileName));
    if (file.open(QIODevice::WriteOnly)) {
        file.write(data.toUtf8());
        return file.flush();
    } else
        return false;
}

QString CommanderHelper::fileName(QString fileName)
{
    if (fileName.startsWith('{')) {
        int length = fileName.indexOf('}') + 1;
        QString dir = fileName.mid(1, length - 2);
        fileName.remove(0, length);

        QStandardPaths::StandardLocation location;
        if (dir == "HOME")
            location = QStandardPaths::HomeLocation;
        else if (dir == "DESKTOP")
            location = QStandardPaths::DesktopLocation;
        else if (dir == "PICTURES")
            location = QStandardPaths::PicturesLocation;
        else if (dir == "MUSICS")
            location = QStandardPaths::MusicLocation;
        else if (dir == "MOVIES")
            location = QStandardPaths::MoviesLocation;
        else if (dir == "DOCUMENTS")
            location = QStandardPaths::DocumentsLocation;
        else if (dir == "DOWNLOADS")
            location = QStandardPaths::DownloadLocation;
        else
            location = QStandardPaths::CacheLocation;

        fileName.prepend(QStandardPaths::writableLocation(location));
    }

    return fileName;
}
