#include <QGuiApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;                                                   // 创建QQmlApplicationEngine实例用与加载和运行QML文件
    const QUrl url(QStringLiteral("qrc:/main.qml"));                                // 指定QML文件路径
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,                // 信号槽连接，以确保在QML对象未成功创建时退出应用程序
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);                                                               // 加载指定QML文件并显示应用程序界面

    return app.exec();
}
