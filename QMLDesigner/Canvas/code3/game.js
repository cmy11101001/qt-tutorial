.import QtQuick 2.15 as QQ

// 音符集合
var notes = Array()
// 界面刷新
function process(ctx) {
    // 重新计算每个计算音符 x, y, width, height
    for (var i=0; i<notes.length; i++) {
        var note = notes[i]
        note.y += 4
        var scale = note.y/640
        note.x = (1-scale)*180 + (480-(1-scale)*180*2)/6*(note.number-1)
        note.width = 20 + scale*60
        note.height = 10 + scale*54
    }
}

// 生成音符
function generatedNote(canvas, number) {
    if (number === 0) return
    var noteComponent = Qt.createComponent("Note.qml")
    if (noteComponent.status === QQ.Component.Ready) {
        var note = noteComponent.createObject(canvas, {
            x: 180+(number-1)*20,
            y: 0,
            width: 20,
            height: 10,
            number: number
        });
        notes.push(note)
    }
}

// 音符越界
function noteOver(canvas){
    for (var i=0; i<notes.length; i++) {
        var note = notes[i]
        if (note.y > (640 + canvas.loose/2)){
            canvas.score = 0
            note.destroy()
            notes[i] = null
            notes.splice(i, 1)
        }
    }
}

// 按键触发
function pressedKeys(canvas, key) {
    switch (key) {
        case Qt.Key_S:
            noteKey(canvas, 1)
            break
        case Qt.Key_D:
            noteKey(canvas, 2)
            break
        case Qt.Key_F:
            noteKey(canvas, 3)
            break
        case Qt.Key_J:
            noteKey(canvas, 4)
            break
        case Qt.Key_K:
            noteKey(canvas, 5)
            break
        case Qt.Key_L:
            noteKey(canvas, 6)
            break
        default:
            console.log("other key pressed")
            break
    }
}

// 按键位置判断
function noteKey(canvas, number) {
    var result = false
    for (var i=0; i<notes.length; i++) {
        if (notes[i].number === number) {
            // 判断当前位置是否在击打键附近，
            var note = notes[i]
            var noteCentreX = note.x + note.width/2
            var noteCentreY = note.y + note.height/2
            var keyCentreX = 80*(number-1) + 40
            var keyCentreY = 608
            var dx = noteCentreX - keyCentreX
            var dy = noteCentreY - keyCentreY
            var distance = Math.sqrt(dx * dx + dy * dy)
            if (distance < canvas.loose) {
                result = true
                note.destroy()
                notes[i] = null
                notes.splice(i, 1)
            }
        }
    }
    if (result === true){
        canvas.score += 1
    } else {
        canvas.score = 0
    }
}
