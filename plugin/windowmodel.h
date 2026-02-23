#pragma once

#include "taskmanager/taskfilterproxymodel.h"

#include <memory>

class PagerModel;

class WindowModel : public TaskManager::TaskFilterProxyModel
{
    Q_OBJECT

public:
    enum WindowModelRoles {
        StackingOrder = Qt::UserRole + 1,
    };
    Q_ENUM(WindowModelRoles)

    explicit WindowModel(PagerModel *parent);
    ~WindowModel() override;

    QHash<int, QByteArray> roleNames() const override;

    QVariant data(const QModelIndex &index, int role) const override;
    
    Q_INVOKABLE void requestActivate(const QModelIndex &index) override;
    Q_INVOKABLE void requestClose(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleMinimized(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleMaximized(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleKeepAbove(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleKeepBelow(const QModelIndex &index) override;
    Q_INVOKABLE void requestNewInstance(const QModelIndex &index) override;
    Q_INVOKABLE void requestResize(const QModelIndex &index) override;
    Q_INVOKABLE void requestMove(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleFullScreen(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleShaded(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleNoBorder(const QModelIndex &index) override;
    Q_INVOKABLE void requestToggleExcludeFromCapture(const QModelIndex &index) override;
    Q_INVOKABLE void requestVirtualDesktops(const QModelIndex &index, const QVariantList &desktops) override;
    Q_INVOKABLE void requestVirtualDesktopPage(const QModelIndex &index, int page);
    Q_INVOKABLE void requestNewVirtualDesktop(const QModelIndex &index) override;

private Q_SLOTS:
    void onPagerItemSizeChanged();

private:
    class Private;
    std::unique_ptr<Private> d;
};
