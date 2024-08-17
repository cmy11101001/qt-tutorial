import QtQuick 2.15
import QtQuick.Window 2.15
import QtMultimedia 5.12
import QtQuick.Controls 2.12

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ffmpeg example")

//    property string path: "E:/Works/QtTutorial/视频教程/QMLDesigner/15. QML教程-13分钟零基础一口气快速入门QML-零废话不墨迹/QML教程-13分钟零基础一口气快速入门QML-零废话不墨迹.mp4"
    property string path: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
//    property string path: "rtmp://ns8.indexforce.com/home/mystream"

    MediaPlayer{
        id:mediaPlayer;
        audioRole: MediaPlayer.VideoRole;
        source: path

        onError: {
            console.log(errorString);
        }
    }
    VideoOutput{
        anchors.fill: parent;
        source: mediaPlayer;
    }

    Button {
        id: play
        text: qsTr("播放")
        x: parent.width * 0.1
        y: (parent.height - height) * 0.98
        onClicked: {
            if (mediaPlayer.playbackState !== Audio.PlayingState) {
                mediaPlayer.play();
                text = qsTr("暂停")
            } else {
                mediaPlayer.pause()
                text = qsTr("播放")
            }
        }
    }

    Slider {
        id: slider
        anchors.top: play.top
        anchors.left: play.right
        anchors.leftMargin: 2
        width: parent.width - parent.width * 0.2 - play.width * 2
        value: mediaPlayer.position / mediaPlayer.duration
        onMoved: {
            if (pressed === true) {
                mediaPlayer.seek(position * mediaPlayer.duration)
            }
        }
    }

    Button {
        text: qsTr("停止")
        anchors.top: play.top
        anchors.left: slider.right
        anchors.leftMargin: 2
        onClicked: {
            mediaPlayer.stop()
            play.text = qsTr("播放")
        }
    }
}
