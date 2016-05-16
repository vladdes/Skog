//------------------------------------------------------------------------------
//Author: vladimir.strukelj@guest.skogsstyrelsen.se

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
    property var checkBoxes: []
    property string skogsTiledMapService: "https://geodata.skogsstyrelsen.se/arcgis/rest/services/SkogligaGrunddata/ImageServer"
    property string esriTiledMapServer: "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5 * displayScaleFactor;

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
                    anchors.centerIn: parent

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
                        id: baseMap
                        url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
                        name: "Esris baskarta."
                        visible: true

                    }
                    ArcGISImageServiceLayer{
                        id: skogsMapComponent
                        name: "Skogstyrelsens baskarta."
                        url: skogsTiledMapService
                        visible: false
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
                    Rectangle {
                        anchors {
                            fill: controlsColumn
                            margins: -10
                        }
                        color: "lightgrey"
                        radius: 5
                        border.color: "black"
                        opacity: 0.77
                    }

                    Column {
                        id: controlsColumn
                        anchors {
                            left: parent.left
                            top: parent.top
                            margins: 20 * scaleFactor
                        }
                        spacing: 10 * scaleFactor

                        Button {
                            id: loadButton
                            text: "Välj karta"
                            style: okButton.style
                            opacity: loadButton.hovered ? 1 : 0.5

                            onClicked: {
                                loadBack.visible = true
                                loadLayerColumn.visible = true
                            }
                        }


                    }

                    Rectangle {
                        anchors.fill: parent
                        id: overlay
                        color: "#000000"
                        opacity: 0.6

                        MouseArea {
                            anchors.fill: parent
                        }

                        visible: loadLayerColumn.visible

                        Rectangle {
                            id: loadBack
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            clip: true
                            width: loadLayerColumn.width + 30 * scaleFactor
                            height: loadLayerColumn.height + 30 * scaleFactor
                            color: "white"
                            radius: 5 * scaleFactor
                            border.color: "white"
                            visible: loadLayerColumn.visible
                        }
                    }

                    Column {
                        id: loadLayerColumn
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 10 * scaleFactor
                        visible: false

                        Text {
                            text: "Välj karta:"
                            font.pixelSize: 14 * scaleFactor
                        }

                        ComboBox{
                            id: choseMapComboBox


                            width: 180 * scaleFactor
                            height: 40 * scaleFactor
                            style: ComboBoxStyle{
                                label: Text {
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pointSize: 10 * scaleFactor
                                    font.capitalization: Font.SmallCaps
                                    color: "black"
                                    text: control.currentText
                                }

                            }

                            model: [baseMap.name, skogsMapComponent.name]
                        }

                        Row {
                            spacing: 10 * scaleFactor

                            Button {
                                id: okButtonMap
                                text: "Ok"
                                style: okButton.style
                                opacity: okButtonMap.hovered ? 1 :0.5
                                onClicked: {

                                    loadLayerColumn.visible = false;
                                    //                                    mainMap.reset();


                                    //                                    var tiledMapService = choseMapComboBox.currentIndex === 0 ? ArcGISRuntime.createObject("ArcGISTiledMapServiceLayer") : ArcGISRuntime.createObject("ArcGISImageServiceLayer");
                                    //                                    tiledMapService.url = choseMapComboBox.currentIndex === 0 ? baseMap.url : skogsMapComponent.url;


                                    skogsMapComponent.visible = choseMapComboBox.currentIndex === 0 ? false : true;
                                    //                                    mainMap.addLayer(tiledMapService);


                                }

                            }

                            Button {
                                id: cancelMapButton
                                text: "Cancel"
                                style: okButton.style
                                opacity: cancelMapButton.hovered ? 1 : 0.5
                                onClicked: loadLayerColumn.visible = false
                            }
                        }
                    }

                    // Dialog for instructions and error messages
                    Rectangle {
                        id: feedbackRectangle
                        anchors {
                            fill: messageColumn
                            margins: -10 * scaleFactor
                        }

                        color: "#31cc3b"
                        radius: 5 * scaleFactor
                        border.color: "white"
                        border.width: 3
                        opacity: 0.77
                        Text {
                            id: infoText
                            text: qsTr("Klicka här för att välja karttjänst.")
                            color: "white"
                            anchors.centerIn: feedbackRectangle
                            font.pixelSize: 12 * scaleFactor
                            font.bold: true

                        }


                    }
                    // Progress bar
                    Row {

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 5 * scaleFactor
                        }

                        ProgressBar {
                            id: progressBar
                            indeterminate: true
                            visible: false
                        }
                    }

                    Flickable{
                        id: flickServices
                        width: parent.width
                        height: parent.height
                        contentHeight: parent.height*3
                        contentWidth: parent.width
                        visible: false


                        Rectangle{
                            id: mapServiceRec
                            anchors.fill: parent
                            color: "#31cc3b"
                            visible: false
                            Text{
                                text: qsTr("Välj bort eller lägg till genom att knacka.")
                                color: "white"
                                anchors{
                                    horizontalCenter: parent.horizontalCenter
                                    top: parent.top
                                    topMargin: 10* scaleFactor
                                }

                                font.pixelSize: 14 * scaleFactor
                                font.bold: true

                            }
                            onVisibleChanged: {
                                if(mapServiceRec.visible === true)
                                    createCheckBoxes();
                                else{
                                    for(var i in checkBoxes){
                                        console.log(checkBoxes.pop(i));

                                    }

                                }
                            }

                        }//mapServiceRec


                    }
                    Button{
                        id: okButton
                        text: "Spara"
                        visible: false
                        anchors{
                            margins: 10 * scaleFactor
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom

                        }

                        style: ButtonStyle {
                            background:Rectangle {
                                implicitWidth: 150 * scaleFactor
                                implicitHeight: 50 * scaleFactor
                                border.width: control.activeFocus ? 2 : 1
                                border.color: "#888"
                                radius: 5
                                color: "white"
                                opacity: okButton.hovered ? 1 : 0.5
                            }
                            label: Text {
                                text: "<b><i>" + control.text + "</b></i>"
                                color:"#3a3a3a"

                                wrapMode: Text.WordWrap
                                font.pixelSize: 14 *scaleFactor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                            }
                        }
                        onClicked: {
                            mapServiceRec.visible = false;
                            flickServices.visible = false;
                            okButton.visible = false;


                        }


                    }

                    MouseArea{
                        id: infoRecArea
                        anchors.fill: feedbackRectangle
                        hoverEnabled: true
                        onClicked:{
                            mapServiceRec.visible = true;
                            okButton.visible = true;
                            flickServices.visible = true;


                        }

                    }

                    Column {
                        id: messageColumn
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
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
                                font.pixelSize: 14 * scaleFactor
                                width: parent.width
                                wrapMode: Text.WordWrap
                                visible: true
                                anchors.centerIn: app
                            }
                        }
                    }
                }


                // Responsewindow for results
                Item {
                    id: identifyDialog
                    visible: false
                    Rectangle {
                        id: dialogRectangle
                        color: "#31cc3b"
                        width : mainMap.width
                        height: mainMap.height
                        anchors.fill: app

                        ListView {
                            model: fieldsModel
                            id: fieldsView
                            //flickableData: elem
                            anchors.fill: parent
                            anchors.bottomMargin: 80
                            contentWidth: parent.width
                            contentHeight: parent.height
                            clip: true
                            delegate: Text {
                                text: {
                                    if(name=== "error")
                                        text = "Inget objekt hittat!";
                                    else
                                        text = name + ": " + value;
                                }
                                color: "white"
                                font.pixelSize: 14 * scaleFactor
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.bold: true

                            }
                        }
                        Button {
                            id: infoButton
                            anchors {
                                bottomMargin: 10 * scaleFactor
                                horizontalCenter: parent.horizontalCenter
                                top: fieldsView.bottom

                            }
                            text: "<b>OK</b>"
                            style: ButtonStyle {
                                background:Rectangle {
                                    implicitWidth: 150 * scaleFactor
                                    implicitHeight: 50 * scaleFactor
                                    border.width: control.activeFocus ? 2 : 1
                                    border.color: "#888"
                                    radius: 5
                                    color: "white"
                                    opacity: infoButton.hovered ? 1 : 0.5
                                }
                                label: Text {
                                    text: control.text
                                    color:"#3a3a3a"

                                    font.pixelSize: 14 * scaleFactor
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
                                var attributeNameDisplayed;

                                console.log("namn: "+appVisaSkogkulturnaturhansyn_2_0_Map.subLayerByName(result.layerName).name);
                                console.log("visible: "+appVisaSkogkulturnaturhansyn_2_0_Map.subLayerByName(result.layerName).visible);
                                var checkVisLayer = "";

                                for(var attributeIndex in result.feature.attributeNames){
                                    var attributeName = result.feature.attributeNames[attributeIndex];
                                    if(appVisaSkogkulturnaturhansyn_2_0_Map.subLayerByName(result.layerName).visible){
                                        var attributeValue = result.feature.attributeValue(attributeName);
                                        if(attributeName !== attributeNameDisplayed && attributeName !== "shape"){
                                            fieldsModel.append({"name": attributeName, "value" : attributeValue});
                                            attributeNameDisplayed = attributeName;
                                        }
                                    }

                                }


                            }
                            if(fieldsModel.count === 0)
                                fieldsModel.append({"name": "error", "value": ""});
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
                }//IdentifyTask


            }//ContentBlock

            Rectangle{
                id: loginRec
                anchors.fill: parent
                color: "#31cc3b"
                visible: true
                Image {
                    id: loginImage
                    source: "front.jpg"
                    anchors.horizontalCenter: parent.horizontalCenter

                }
                Text{
                    text:"Här finns registrerade hänsynskrävande skogsområden och kulturlämningar i svenska skogar. Dessutom kan du via GPS se din egen position i kartan på telefonen eller plattan."
                    color: "white"
                    anchors{
                        top: loginImage.bottom
                        right: parent.right
                        left: parent.left
                        margins:  15* scaleFactor
                    }
                    wrapMode: Text.Wrap
                    font.pixelSize: 20 * scaleFactor
                    font.bold: true

                }
                Row {

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 5 * scaleFactor
                    }

                    ProgressBar {
                        id: loginBar
                        indeterminate: true
                        visible: false
                    }
                }
                Button {
                    id: loginButton
                    anchors {
                        bottomMargin: 40 * scaleFactor
                        horizontalCenter: loginRec.horizontalCenter
                        bottom: loginRec.bottom
                    }
                    text: "<b>OK</b>"
                    style: ButtonStyle {
                        background:Rectangle {
                            implicitWidth: 150 * scaleFactor
                            implicitHeight: 50 * scaleFactor
                            border.width: control.activeFocus ? 2 : 1
                            border.color: "#888"
                            radius: 5
                            color: "white"
                            opacity: loginButton.hovered ? 1 : 0.5
                        }
                        label: Text {
                            text: control.text
                            color:"#3a3a3a"

                            font.pixelSize: 14 * scaleFactor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }


                    onClicked:{
                        loginBar.visible = true;
                        if(baseMap.status === 2){
                            loginBar.visible = false;
                            loginRec.visible = false;
                            loginButton.visible = false;
                        }
                        else{
                            loginButton.text = "Försök igen!";
                        }

                    }

                }


            }


        }//GridLayout



    }



    //Creates a new checkbox for each layer.
    function createCheckBoxes(){
        for(var i in appVisaSkogkulturnaturhansyn_2_0_Map.layers){
            var margin = 50 * scaleFactor;
            var checkBoxDef = "import QtQuick 2.4
                               import QtQuick.Controls 1.2
                               import QtQuick.Controls.Styles 1.4
                                   CheckBox{
                                      id: checkB"+i+"
                                      checked: appVisaSkogkulturnaturhansyn_2_0_Map.layers["+i+"].visible ? true : false;

                                      Text{
                                        text: '<b>' + appVisaSkogkulturnaturhansyn_2_0_Map.layers["+i+"].name + '<b>'
                                        font.pixelSize: 14 * scaleFactor
                                        color: '#FFFFFF'
                                        anchors.centerIn: parent
                                        wrapMode: Text.WrapAnywhere

                                      }
                                      style: CheckBoxStyle {
                                            indicator: Rectangle {
                                                implicitWidth: 250 * scaleFactor
                                                implicitHeight: 50 * scaleFactor
                                                radius: 3

                                                border.color: control.activeFocus ? 'darkblue' : 'gray'
                                                border.width: 1
                                                Rectangle{
                                                    visible: control.checked
                                                    color: '#228e29'
                                                    border.color: '#333'
                                                    radius: 1
                                                    anchors.margins: 4
                                                    anchors.fill: parent
                                                }
                                                Rectangle{
                                                    visible: !control.checked
                                                    color: 'grey'

                                                    radius: 1
                                                    anchors.margins: 4
                                                    anchors.fill: parent
                                                }
                                            }
                                        }
                                      anchors{
                                            top: parent.top
                                            topMargin: "+ (margin + margin * i)+"
                                            horizontalCenter: parent.horizontalCenter

                                      }

                                onCheckedChanged: {
                                    updateVisibility("+i+",checked);


                                }



                 }";

            var currentBox = Qt.createQmlObject(checkBoxDef, mapServiceRec, 'obj' + i);
            checkBoxes.push(currentBox);



        }//forloop

    }

    function updateVisibility(layerIndex, visible) {

        appVisaSkogkulturnaturhansyn_2_0_Map.layers[layerIndex].visible = visible;
        appVisaSkogkulturnaturhansyn_2_0_Map.refresh();

    }


}
