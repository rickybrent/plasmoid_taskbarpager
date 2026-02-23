/*
    SPDX-FileCopyrightText: 2013-2016 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QObject>
#include <QRect>

#include <netwm.h>
#include <qqmlregistration.h>
#include <qwindowdefs.h>

class QAction;
class QActionGroup;
class QQuickItem;
class QQuickWindow;
class QJsonArray;

class LaunchBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum MiddleClickAction {
        None = 0,
        Close,
        NewInstance,
        ToggleMinimized,
        ToggleGrouping,
        BringToCurrentDesktop,
    };

    Q_ENUM(MiddleClickAction)

    explicit LaunchBackend(QObject *parent = nullptr);
    ~LaunchBackend() override;

    Q_INVOKABLE QVariantList jumpListActions(const QUrl &launcherUrl, QObject *parent);
    Q_INVOKABLE void setActionGroup(QAction *action) const;

    Q_INVOKABLE QRect globalRect(QQuickItem *item) const;

    Q_INVOKABLE bool isApplication(const QUrl &url) const;

    Q_INVOKABLE static QUrl tryDecodeApplicationsUrl(const QUrl &launcherUrl);
    Q_INVOKABLE static QStringList applicationCategories(const QUrl &launcherUrl);

Q_SIGNALS:
    void addLauncher(const QUrl &url) const;

private:
    QActionGroup *m_actionGroup = nullptr;
};
