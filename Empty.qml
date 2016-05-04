//------------------------------------------------------------------------------

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtPositioning 5.3
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0



import "./Components"
App {
    id: app
    width: 800
    height: 640

    property real displayScaleFactor : AppFramework.displayScaleFactor
    property bool isLandscape : width > height
    property double scaleFactor: AppFramework.displayScaleFactor
    property string appVisaSkogkulturnaturhansyn_2_0: "http://gedpagstest.skogsstyrelsen.se/arcgis/rest/services/App/AppVisaSkogkulturnaturhansyn_2_0/MapServer"


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5 * displayScaleFactor;


        ToolBar {
            id: toolbar
            Layout.fillWidth: true

            RowLayout {
                ToolButton {
                    id: errorButton
                    text: ""
                    onClicked: errorButton.text = ""

                }
            }
        }

        GridLayout {
            id: grid
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: app.isLandscape ? children.length : 1
            rows: app.isLandscape ? 1 : children.length

            //            LayoutMirroring.enabled: app.isLandscape
            //            LayoutMirroring.childrenInherit: true

            //            SidePanel {
            //                itemRotation: isPanelMinimised ? 180 : 0
            //            }

            ContentBlock {

                Map {
                    id: mainMap
                    anchors.fill: parent
                    extent: usExtent
                    focus: true
                    anchors.centerIn: app

                    positionDisplay {
                        positionSource: PositionSource {
                        }
                    }

                    ZoomButtons {

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 30
                        }
                    }

                    ArcGISTiledMapServiceLayer {
                        url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"



                    }



                    ArcGISDynamicMapServiceLayer {
                        url: appVisaSkogkulturnaturhansyn_2_0
                        id: appVisaSkogkulturnaturhansyn_2_0_Map
                        visible: true


                    }


                    // Starting map extent

                    Envelope {
                        id: usExtent
                        xMin: 850000
                        yMin: 8700000
                        xMax: 2800000
                        yMax: 9500000
                        spatialReference: mainMap.spatialReference
                    }

                    SimpleMarkerSymbol {
                        id: simpleMarkerSymbolIdentifyLocation
                        color: "blue"
                        style: Enums.SimpleLineSymbolStyleDashDot
                        size: 16
                    }

                    Graphic {
                        id: identifyGraphic
                        symbol: simpleMarkerSymbolIdentifyLocation
                    }

                    GraphicsLayer {
                        id: graphicsLayer
                    }

                    // Initiation of the identify task

                    onMouseClicked: {

                        resultsRow.visible = false;
                        identifyDialog.visible = false;
                        progressBar.visible = true;

                        graphicsLayer.removeAllGraphics();
                        var graphic1 = identifyGraphic.clone();
                        graphic1.geometry = mouse.mapPoint;
                        graphicsLayer.addGraphic(graphic1);

                        identifyParameters.geometry = mouse.mapPoint;
                        identifyParameters.mapExtent = mainMap.extent;
                        identifyParameters.mapHeight = mainMap.height;
                        identifyParameters.mapWidth = mainMap.width;
                        identifyParameters.layerMode = Enums.LayerModeVisibleLayers;
                        identifyParameters.DPI =  Screen.pixelDensity * 25.4;


                        identifyTask.execute(identifyParameters);

                    }

                    // Dialog for instructions and error messages
                    Rectangle {
                        id: feedbackRectangle
                        anchors {
                            fill: messageColumn
                            margins: -10 * scaleFactor
                        }
                        color: "lightgrey"
                        radius: 5 * scaleFactor
                        border.color: "black"
                        opacity: 0.77
                        Text {
                            id: infoText
                            text: qsTr("Klicka här för att välja karttjänst")

                            anchors.centerIn: feedbackRectangle


                        }




                    }

                    Rectangle{
                        id: mapServiceRec
                        anchors.fill: mainMap
                        color: "white"
                        border.color: "gray"
                        border.width: 2
                        visible: false

                        CheckBox {
                            id: avverkningCheck
                            checked: true

                            Text{
                                text: "<b>Avverkning<b>"
                                font.pointSize: 18
                                anchors{
                                    horizontalCenter: parent.horizontalCenter
                                    verticalCenter: parent.verticalCenter
                                }
                            }
                            anchors{
                                verticalCenter: parent.verticalCenter

                                left: parent.left
                                leftMargin: 10* scaleFactor


                            }
                            style: CheckBoxStyle {
                                indicator: Rectangle {
                                    implicitWidth: Screen.width/12
                                    implicitHeight: Screen.height/16
                                    radius: 3
                                    border.color: control.activeFocus ? "darkblue" : "gray"
                                    border.width: 1

                                    Rectangle{
                                        visible: control.checked
                                        color: "#C0C0C0"
                                        border.color: "#333"
                                        radius: 1
                                        anchors.margins: 4
                                        anchors.fill: parent


                                    }
                                }

                            }
                            onCheckedChanged: {
                                updateVisibility(1,checked);
                                updateVisibility(0, checked);
                                updateVisibility(2,checked);

                            }


                        }

                        Button{
                            id: okButton
                            text: "Spara"

                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                margins: 10 * scaleFactor
                                bottom: mapServiceRec.bottom

                            }
                            style: ButtonStyle {
                                background:Rectangle {
                                    implicitWidth: Text.Wrap
                                    implicitHeight: Text.Wrap
                                    border.width: control.activeFocus ? 2 : 1
                                    border.color: "#888"
                                    radius: 2
                                    gradient: Gradient {
                                        GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                                        GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                                    }
                                }
                                label: Text {
                                    text: "<b><i>" + control.text + "</b></i>"
                                    color:"#3a3a3a"


                                    font.pointSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            onClicked: {
                                mapServiceRec.visible = false;
                            }


                        }

                       Component.onCompleted: {
                         console.log(appVisaSkogkulturnaturhansyn_2_0_Map.subLayerById(0).name);
                       }
                    }


                    MouseArea{
                        id: infoRecArea
                        anchors.fill: feedbackRectangle
                        hoverEnabled: true
                        onClicked: mapServiceRec.visible = true

                    }

                    Column {
                        id: messageColumn
                        anchors {
                            top: parent.top
                            left: parent.left
                            margins: 20 * scaleFactor
                        }
                        width: 210 * scaleFactor
                        spacing: 10 * scaleFactor

                        Row {
                            id: intructionsRow
                            spacing: 10 * scaleFactor
                            visible: true
                            width: parent.width

                            Text {
                                text: qsTr("")
                                font.pixelSize: 14 * scaleFactor
                                width: parent.width
                                wrapMode: Text.WordWrap
                                visible: true
                            }
                        }

                        Row {
                            id: resultsRow
                            spacing: 10 * scaleFactor
                            visible: false
                            width: parent.width

                            Text {
                                id: resultText
                                text: qsTr("")
                                font.pixelSize: 12 * scaleFactor
                                width: parent.width
                                wrapMode: Text.WordWrap
                                visible: true
                                anchors.centerIn: app
                            }
                        }
                    }
                }

                // Progress bar
                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: mainMap.bottom
                        bottomMargin: 5 * scaleFactor
                    }

                    ProgressBar {
                        id: progressBar
                        indeterminate: true
                        visible: false
                    }
                }

                Rectangle {
                    id: rectangleBorder
                    anchors.fill: parent
                    color: "transparent"
                    border {
                        width: 0.5 * scaleFactor
                        color: "black"
                    }
                }

                // Responsewindow for results
                Item {
                    id: identifyDialog
                    visible: false
                    Rectangle {
                        id: dialogRectangle
                        color: "lightgrey"
                        width : mainMap.width
                        height: mainMap.height
                        anchors.fill: mainMap

                        ListView {
                            model: fieldsModel
                            id: fieldsView
                            //flickableData: elem
                            anchors.fill: parent
                            contentWidth: parent.width
                            contentHeight: parent.height
                            clip: true
                            delegate: Text {
                                text: name + ": " + value
                            }
                        }
                        Button {
                            id: infoButton
                            anchors {
                                margins: 10 * scaleFactor
                                horizontalCenter: parent.horizontalCenter
                                bottom: fieldsView.bottom


                            }
                            text: "OK"
                            style: ButtonStyle {
                                background:Rectangle {
                                    implicitWidth: identifyDialog.width/ 2
                                    implicitHeight: identifyDialog.height / 6
                                    border.width: control.activeFocus ? 2 : 1
                                    border.color: "#888"
                                    radius: 4
                                    gradient: Gradient {
                                        GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                                        GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                                    }
                                }
                                label: Text {
                                    text: control.text
                                    color:"#3a3a3a"

                                    font.pixelSize: infoButton.height /2
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            onClicked: identifyDialog.visible = false;
                        }
                    }

                }

                ListModel {
                    id:fieldsModel
                }

                // Identify task components
                IdentifyParameters {
                    id: identifyParameters


                }


                IdentifyTask {
                    id: identifyTask
                    url: appVisaSkogkulturnaturhansyn_2_0


                    onIdentifyTaskStatusChanged: {
                        if (identifyTaskStatus === Enums.IdentifyTaskStatusCompleted) {
                            resultText.text = "";
                            fieldsModel.clear();

                            for (var index in identifyResult) {

                                var result = identifyResult[index];
                                for(var i in appVisaSkogkulturnaturhansyn_2_0_Map.layers)
                                    console.log("sublayer:" + appVisaSkogkulturnaturhansyn_2_0_Map.layers[i].subLayerIds);

                                if(appVisaSkogkulturnaturhansyn_2_0_Map.subLayerById(index).visible === true){
                                    for(var attributeIndex in result.feature.attributeNames){
                                        var attributeName = result.feature.attributeNames[attributeIndex];
                                        var attributeValue = result.feature.attributeValue(attributeName);
                                        fieldsModel.append({"name": attributeName, "value" : attributeValue});

                                    }
                                }

                            }
                            if (fieldsModel.count === 0)
                                fieldsModel.append({"name": "Results", "value": "none"});
                            identifyDialog.visible = true;
                            if(Qt.platform.os !== "ios" && Qt.platform.os != "android") {
                                identifyDialog.width = 365 * scaleFactor
                                identifyDialog.height = 400 * scaleFactor
                            }
                            progressBar.visible = false;
                        } else if (identifyTaskStatus === Enums.IdentifyTaskStatusErrored) {
                            resultText.text = identifyError.message;
                            resultsRow.visible = true;
                            identifyDialog.visible = false;
                            progressBar.visible = false;
                        }
                    }
                }


            }



        }


    }

    function createCheckBoxes(){
        for(var i in appVisaSkogkulturnaturhansyn_2_0_Map.layers){
            for(var j in appVisaSkogkulturnaturhansyn_2_0_Map.layers[i].subLayerIds){
                if(i !== appVisaSkogkulturnaturhansyn_2_0_Map.layers[i].subLayerIds[j]){
                    var checkBoxDef = "import QtQuick 2.0
                                       import QtQuick.Controls 1.2
                                       import QtQuick.Controls.Styles 1.4
                                           CheckBox{
                                              id: appVisaSkogkulturnaturhansyn_2_0_Map.layers["+i+"].name;
                                              checked: true;
                                              Text{
                                                text: '<b>' + appVisaSkogkulturnaturhansyn_2_0_Map.layers["+i+"].name + '<b>'
                                                font.pointSize: 15
                                                anchors{
                                                    horizontalCenter: mapServiceRec.horizontalCenter
                                                    verticalCenter: mapServiceRec.verticalCenter
                                                }
                                             }
                                        anchors{
                                            verticalCenter: parent.verticalCenter

                                            left: parent.left
                                            leftMargin: 10* scaleFactor

                                        }

                                        style: CheckBoxStyle {
                                            indicator: Rectangle {
                                                implicitWidth: Screen.width/12
                                                implicitHeight: Screen.height/16
                                                radius: 3
                                                border.color: control.activeFocus ? 'darkblue' : 'gray'
                                                border.width: 1

                                                Rectangle{
                                                    visible: control.checked
                                                    color: '#C0C0C0'
                                                    border.color: '#333'
                                                    radius: 1
                                                    anchors.margins: 4
                                                    anchors.fill: parent


                                                }
                                            }

                                        }
                                        onCheckedChanged: {
                                            updateVisibility("+i+",checked);
                                            for(var ix = 0; ix <= appVisaSkogkulturnaturhansyn_2_0_Map.layers["+i+"].subLayerIds.length; ix++){
                                                var layerIds = appVisaSkogkulturnaturhansyn_2_0_Map.layers["+i+"].subLayerIds[ix];
                                                updateVisibility(layerIds,checked);
                                            }
                                        }

                         }";
                    Qt.createQmlObject(checkBoxDef, mapServiceRec, 'obj' + i);
                }
            }
        }

    }

    function updateVisibility(layerIndex, visible) {
        console.log("sublayer:" + appVisaSkogkulturnaturhansyn_2_0_Map.layers[0].subLayerIds);
        appVisaSkogkulturnaturhansyn_2_0_Map.subLayerById(layerIndex).visible = visible;
        appVisaSkogkulturnaturhansyn_2_0_Map.refresh();

    }


}


