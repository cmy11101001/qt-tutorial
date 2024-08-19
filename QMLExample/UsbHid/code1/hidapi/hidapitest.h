#ifndef HIDAPITEST_H
#define HIDAPITEST_H

#include <QObject>

class HidapiTest : public QObject
{
    Q_OBJECT
public:
    explicit HidapiTest(QObject *parent = nullptr);

signals:

};

#endif // HIDAPITEST_H
