set(taskbarpager_source
        pagermodel.cpp
        pagermodel.h
        windowmodel.cpp
        windowmodel.h
        backend.cpp
        backend.cpp
)

find_package(LibTaskManager REQUIRED)
find_package(KF6KIO REQUIRED)


qt_add_qml_module(taskbarpager
    URI "com.github.rickybrent.taskbarpager"
    VERSION 1.0
    SOURCES ${taskbarpager_source}
)

set_target_properties(taskbarpagerplugin PROPERTIES
    PREFIX "lib"
)

target_include_directories(taskbarpager PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(taskbarpager
    PRIVATE
        Qt::Core
        Qt::DBus
        Qt::Qml
        Qt::Widgets
		Qt::Quick
        KF6::KIOCore
        KF6::KIOGui
        KF6::I18n
        KF6::Service
        KF6::WindowSystem    
        KWin::kwin
        Plasma::Plasma
        Plasma::Activities
		PW::LibTaskManager
)

install(TARGETS taskbarpager
    DESTINATION ${KDE_INSTALL_LIBDIR}
)

install(TARGETS taskbarpagerplugin
    DESTINATION ${KDE_INSTALL_QMLDIR}/com/github/rickybrent/taskbarpager
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/qmldir
    ${CMAKE_CURRENT_BINARY_DIR}/taskbarpager.qmltypes
    DESTINATION ${KDE_INSTALL_QMLDIR}/com/github/rickybrent/taskbarpager
)
