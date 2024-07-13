#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);
    static Backend* instance(){                                             // 获取单例
        if(m_instance == nullptr) {
            m_instance = new Backend();
        }
        return m_instance;
    }

    Q_INVOKABLE void receive(const QString &msg);                           // 接收前端QML的消息

signals:
    void message(QString msg);                                              // 发送消息给前端QML

private:
    static Backend *m_instance;                                             // 单例
};

class Backend2 : public QObject
{
    Q_OBJECT
public:
    explicit Backend2(QObject *parent = nullptr);

    Q_INVOKABLE void receive(const QString &msg);                           // 接收前端QML的消息

signals:
    void message(QString msg);                                              // 发送消息给前端QML
};

#endif // BACKEND_H
