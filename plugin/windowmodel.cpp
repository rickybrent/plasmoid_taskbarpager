#include "windowmodel.h"
#include "pagermodel.h"

#include <taskmanager/abstracttasksmodel.h>
#include <taskmanager/virtualdesktopinfo.h>

#include <QGuiApplication>
#include <QMetaEnum>
#include <QScreen>

#include <KWindowSystem>
#include <KX11Extras>

using namespace TaskManager;

class WindowModel::Private
{
public:
    explicit Private(WindowModel *q);

    PagerModel *pagerModel = nullptr;

private:
    WindowModel *const q;
};

WindowModel::Private::Private(WindowModel *q)
    : q(q)
{
    Q_UNUSED(this->q);
}

WindowModel::WindowModel(PagerModel *parent)
    : TaskFilterProxyModel(parent)
    , d(new Private(this))
{
    d->pagerModel = parent;
    connect(parent, &PagerModel::pagerItemSizeChanged, this, &WindowModel::onPagerItemSizeChanged);
    connect(this, &QAbstractItemModel::dataChanged, this, [this](const QModelIndex &topLeft, const QModelIndex &bottomRight, const QList<int> &roles) {
        if (roles.contains(AbstractTasksModel::StackingOrder)) {
            Q_EMIT dataChanged(topLeft, bottomRight, {WindowModelRoles::StackingOrder});
        }
    });
}

WindowModel::~WindowModel()
{
}

QHash<int, QByteArray> WindowModel::roleNames() const
{
    QHash<int, QByteArray> roles = TaskFilterProxyModel::roleNames();

    QMetaEnum e = metaObject()->enumerator(metaObject()->indexOfEnumerator("WindowModelRoles"));

    for (int i = 0; i < e.keyCount(); ++i) {
        roles.insert(e.value(i), e.key(i));
    }

    return roles;
}

QVariant WindowModel::data(const QModelIndex &index, int role) const
{
    if (role == AbstractTasksModel::Geometry) {
        QRect windowGeo = TaskFilterProxyModel::data(index, role).toRect();
        const QRect clampingRect(QPoint(0, 0), d->pagerModel->pagerItemSize());

        if (KWindowSystem::isPlatformX11() && KX11Extras::mapViewport()) {
            int x = windowGeo.center().x() % clampingRect.width();
            int y = windowGeo.center().y() % clampingRect.height();

            if (x < 0) {
                x = x + clampingRect.width();
            }

            if (y < 0) {
                y = y + clampingRect.height();
            }

            const QRect mappedGeo(x - windowGeo.width() / 2, y - windowGeo.height() / 2, windowGeo.width(), windowGeo.height());

            if (filterByScreen() && screenGeometry().isValid()) {
                const QPoint &screenOffset = screenGeometry().topLeft();

                windowGeo = mappedGeo.translated(0 - screenOffset.x(), 0 - screenOffset.y());
            }
        } else if (filterByScreen() && screenGeometry().isValid()) {
            const QPoint &screenOffset = screenGeometry().topLeft();

            windowGeo.translate(0 - screenOffset.x(), 0 - screenOffset.y());
        }

        // Restrict to desktop/screen rect.
        return windowGeo.intersected(clampingRect);
    } else if (role == StackingOrder) {
        const auto &winId = TaskFilterProxyModel::data(index, AbstractTasksModel::WinIdList);
        const int z = d->pagerModel->stackingOrder(index);

        if (z != -1) {
            return z;
        }
        return 0;
    }

    return TaskFilterProxyModel::data(index, role);
}

void WindowModel::requestActivate(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestActivate(index);
}

void WindowModel::requestClose(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestClose(index);
}

void WindowModel::requestToggleMinimized(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleMinimized(index);
}

void WindowModel::requestToggleMaximized(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleMaximized(index);
}

void WindowModel::requestToggleKeepAbove(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleKeepAbove(index);
}

void WindowModel::requestToggleKeepBelow(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleKeepBelow(index);
}

void WindowModel::requestNewInstance(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestNewInstance(index);
}

void WindowModel::requestResize(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestResize(index);
}

void WindowModel::requestMove(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestMove(index);
}

void WindowModel::requestToggleFullScreen(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleFullScreen(index);
}

void WindowModel::requestToggleShaded(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleShaded(index);
}

void WindowModel::requestToggleNoBorder(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleNoBorder(index);
}

void WindowModel::requestToggleExcludeFromCapture(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestToggleExcludeFromCapture(index);
}

void WindowModel::requestVirtualDesktops(const QModelIndex &index, const QVariantList &desktops)
{
    TaskManager::TaskFilterProxyModel::requestVirtualDesktops(index, desktops);
}

void WindowModel::requestVirtualDesktopByPage(const QModelIndex &index, int page)
{
    TaskManager::VirtualDesktopInfo info;
    const QVariantList desktopIds = info.desktopIds();
    
    // Ensure the page requested is within the bounds of available desktops
    if (page >= 0 && page < desktopIds.count()) {
        // Pass the mapped virtual desktop ID to the proxy model
        TaskManager::TaskFilterProxyModel::requestVirtualDesktops(index, {desktopIds.at(page)});
    }
}

void WindowModel::requestNewVirtualDesktop(const QModelIndex &index)
{
    TaskManager::TaskFilterProxyModel::requestNewVirtualDesktop(index);
}


void WindowModel::onPagerItemSizeChanged()
{
    if (rowCount() > 0) {
        Q_EMIT dataChanged(index(0, 0), index(rowCount() - 1, 0), {AbstractTasksModel::Geometry});
    }
}

#include "moc_windowmodel.cpp"
