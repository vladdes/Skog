import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

CheckBox{

    checked: true;
    style: CheckBoxStyle {
        indicator: Rectangle {
            implicitWidth: Screen.width/12
            implicitHeight: Screen.height/16
            radius: 3
            border.color: control.activeFocus ? 'darkblue' : 'gray'
            border.width: 1

            Rectangle{
                visible: control.checked
                color: 'green'
                border.color: '#333'
                radius: 1
                anchors.margins: 4
                anchors.fill: parent


            }
        }

    }

}
