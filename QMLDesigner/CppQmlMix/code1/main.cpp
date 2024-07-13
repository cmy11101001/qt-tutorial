#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend.h"

static QObject *GetBackend(QQmlEngine *engine, QJSEngine *scriptEngine)                 // 定义一个用于qmlRegisterSingletonType接收的回调。
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return Backend::instance();
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    qmlRegisterSingletonType<Backend>("My.Backend", 1, 0, "Backend", GetBackend);       // 方法1，将后端单例注册到QML使用
    engine.rootContext()->setContextProperty("Backend2", new Backend2);                 // 方法2，将后端实例设置成QML的属性使用
    engine.load(url);

    return app.exec();
}
