pyinstaller.exe .\main.py -Dw
md dist\main\qml
XCOPY qml dist\main\qml /E
md dist\main\resource
XCOPY resource dist\main\resource /E
md dist\main\ui
XCOPY ui dist\main\ui /E
md dist\main\log
XCOPY log dist\main\log /E
