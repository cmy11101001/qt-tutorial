#include "backend.h"

Backend* Backend::m_instance = nullptr;
Backend::Backend(QObject *parent)
    : QObject{parent}
{

}

void Backend::receive(const QString &msg){
    emit message(msg);
}

Backend2::Backend2(QObject *parent)
    : QObject{parent}
{

}

void Backend2::receive(const QString &msg){
    emit message(msg);
}
