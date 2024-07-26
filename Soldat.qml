import QtQuick 2.3
import QtGraphicalEffects 1.0

import "soldat"

//   ______       _     _                ______                    _       
//  / _____)     | |   | |        _     (_____ \                  (_)      
// ( (____   ___ | | __| |_____ _| |_    _____) )_____  ____  ____ _  ___  
//  \____ \ / _ \| |/ _  (____ (_   _)  |  __  /(____ |/ _  |/ _  | |/ _ \ 
//  _____) ) |_| | ( (_| / ___ | | |_   | |  \ \/ ___ ( (_| ( (_| | | |_| |
// (______/ \___/ \_)____\_____|  \__)  |_|   |_\_____|\___ |\___ |_|\___/ 
//                                                    (_____(_____|        

Item {
    id: root

    width: 800
    height: 480
    
    z: 0
    
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    property bool udp_up: udp_message & 0x01
    property bool udp_down: udp_message & 0x02
    property bool udp_left: udp_message & 0x04
    property bool udp_right: udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: inputs & 0x01
    property bool battery: inputs & 0x02
    property bool lapmarker: inputs & 0x04
    property bool rearfog: inputs & 0x08
    property bool mainbeam: inputs & 0x10
    property bool up_joystick: inputs & 0x20 || root.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || root.udp_down
    property bool doorswitch: inputs & 0x4000
    property bool airbag: inputs & 0x8000
    property bool tc: inputs & 0x10000
    property bool abs: inputs & 0x20000
    property bool mil: inputs & 0x40000
    property bool shift1_id: inputs & 0x80000
    property bool shift2_id: inputs & 0x100000
    property bool shift3_id: inputs & 0x200000
    property bool service_id: inputs & 0x400000
    property bool race_id: inputs & 0x800000
    property bool sport_id: inputs & 0x1000000
    property bool cruise_id: inputs & 0x2000000
    property bool reverse: inputs & 0x4000000
    property bool handbrake: inputs & 0x8000000
    property bool tc_off: inputs & 0x10000000
    property bool left_joystick: inputs & 0x20000000 || root.udp_left
    property bool right_joystick: inputs & 0x40000000 || root.udp_right

    property int odometer: rpmtest.odometer0data/10*0.62 //Need to div by 10 to get 6 digits with leading 0
    property int tripmeter: rpmtest.tripmileage0data*0.62
    property real value: 0
    property real shiftvalue: 0

    property real rpm: rpmtest.rpmdata
    property real rpmlimit: 8000 
    property real rpmdamping: 5
    property real speed: rpmtest.speeddata
    property int speedunits: 2

    property real watertemp: rpmtest.watertempdata
    property real waterhigh: 0
    property real waterlow: 80
    property real waterunits: 1

    property real fuel: rpmtest.fueldata
    property real fuelhigh: 0
    property real fuellow: 0
    property real fuelunits
    property real fueldamping

    property real o2: rpmtest.o2data
    property real map: rpmtest.mapdata
    property real maf: rpmtest.mafdata

    property real oilpressure: rpmtest.oilpressuredata
    property real oilpressurehigh: 0
    property real oilpressurelow: 0
    property real oilpressureunits: 0

    property real oiltemp: rpmtest.oiltempdata
    property real oiltemphigh: 90
    property real oiltemplow: 90
    property real oiltempunits: 1
    property real oiltemppeak: 0

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: (speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata


    property string white_color: "#FFFFFF"
    property string primary_color: "#FF0000" //#FFBF00 for amber
    property string lit_primary_color: "#F59713" //lit orange
    property string warning_color: "#FF1100" //Warning Red
    property string tachbar: "#FF0000"
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"


    property int timer_time: 1

    //Peak Values

    property int peak_rpm: 0
    property int peak_speed: 0
    property int peak_water: 0
    property int peak_oil: 0
    property bool car_movement: false
    x: 0
    y: 0

    FontLoader {
        id: dESG7BoldItalic
        source: "./fonts/DSEG7Modern-BoldItalic.ttf"
    }
    FontLoader{
        id: dESG7Italic
        source: "./fonts/DSEG7Modern-Italic.ttf"
    }

    //For our Oil/Water Temperatures
    function getBarSource(src){
        if(root.sidelight){ bar_directory = "bars_lit"} 
        if(!root.sidelight){ bar_directory = "bars_unlit"}
        if(src === "OIL"){
            return './kamata/'+ bar_directory + '/'+ Math.min(Math.max(0,Math.round((root.oiltemp.toFixed(0))/10)),15) + '.png'
        }
        else{
            return './kamata/'+ bar_directory + '/'+Math.min(Math.max(0,(Math.round(root.watertemp.toFixed(0)*.125))),15) + '.png'
        }
    }

    //Master Function for peak values
    function checkPeaks(){
        if(root.rpm > root.peak_rpm){
            root.peak_rpm = root.rpm
        }
        if(root.speed > root.peak_speed){
            root.peak_speed = root.speed
        }
        if(root.watertemp > root.peak_water){
            root.peak_water = root.watertemp
        }
        if(root.oiltemp > root.peak_oil){
            root.peak_oil = root.oiltemp
        }
        if(root.speed > 10 && !root.car_movement){
            root.car_movement = true
        }
    }
   
    //Utility  
    function easyFtemp(degreesC){
        return ((((degreesC.toFixed(0))*9)/5)+32).toFixed(0)
    }
    
    function getPeakSpeed(){
        if (root.speedunits === 0) return root.peak_speed.toFixed(0); else return (root.peak_speed*.62).toFixed(0)
    }

    function getTemp(fluid){
        if(fluid == "COOLANT"){
            if(root.seatbelt && root.car_movement && root.speed === 0){ 
                 if(root.waterunits !== 1)
                    return easyFtemp(root.peak_water)
                else 
                    return root.peak_water.toFixed(0)
            }
            else{
                if(root.waterunits !== 1)
                    return easyFtemp(root.watertemp)
                else 
                    return root.watertemp.toFixed(0)
            }
        }
        else{
            if(root.seatbelt && root.car_movement && root.speed === 0){
                 if(root.oiltempunits !== 1)
                    return easyFtemp(root.peak_oil)
                else 
                    return root.peak_oil.toFixed(0)
            }
            else{
                if(root.oiltempunits !== 1)
                    return easyFtemp(root.oiltemp)
                else 
                    return root.oiltemp.toFixed(0)
            }
        }
    }
    
    //Master Timer 
    Timer{
        interval: 2; running: true; repeat: true
        onTriggered: checkPeaks()
    }

    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Rectangle {
        id: background_rect
        x: 0
        y: 0
        width: 800
        height: 480
        color: root.background_color
        border.width: 0
        z: 0
    }

    Image{
        id: tach_speed_bkg
        z:2
        x: 189.5; y: 29.6
        opacity: 0
        source: if(!root.sidelight) './soldat/tach_bkg.png'; else './soldat/s_light/tach_bkg.png'
        Timer{
            interval: 0; running: root.ignition; repeat: false
            onTriggered: animateTachBkg.start()
        }
    }
    SequentialAnimation{
            id: animateTachBkg
            NumberAnimation{
                target: tach_speed_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
        }
    Image{
        id: shift_light
        z: 3
        x: 352; y: 117
        width: 20
        height: 20
        source: './soldat/shiftlight.png'
    }

    Image{
        id: shift_light_blink
        z: 3
        x: 332.5; y: 98
        width: 57
        height: 58
        source: './soldat/shiftlight_lit.png'
        visible: if(root.rpm >= root.rpmlimit) true; else false
        Timer{
            id: rpm_shift_blink
            running: true
            interval: 50
            repeat: true
            onTriggered: if(parent.opacity === 0){
                parent.opacity = 100
            }
            else{
                parent.opacity = 0
            } 
        }
    }
    Item{
        id: tach_group
        opacity: 0
        z: 5
        Image{
            id: tach_needle
            z: 5
            x: 390.5; y: 200.8
            source: if(!root.sidelight) './soldat/orange_tach_needle.png'; else './soldat/red_tach_needle.png'
            transform:[
                    Rotation {
                        id: tachneedle_rotate
                        origin.y: 40
                        origin.x: 10
                        angle: root.rpm.toFixed(0) * .0225       
                        Behavior on angle{
                            SpringAnimation {
                                spring: 1.2
                                damping:.16
                            }
                        }
                    }
                ]
                
        }
    
        DropShadow {
            z: 4
            anchors.fill: tach_needle
            horizontalOffset: 2
            verticalOffset: 2
            radius: 15
            antialiasing: true
            samples: 16
            color: "#000000"
            source: tach_needle
            cached: true  //Save us some rendering
            transform:[
                Rotation {
                    id: shadowneedleRotation
                    origin.y: 40
                    origin.x: 10
                    angle: root.rpm.toFixed(0) * .0225             
                    Behavior on angle{
                        SpringAnimation {
                            spring: 1.2
                            damping:.16
                        }
                    }
                }
            ]
        }
        Timer{
            interval: 2500; running: root.ignition; repeat: false
            onTriggered: animateNeedles.start()
        }
    }   
    ParallelAnimation{
        id: animateNeedles
        NumberAnimation{
            target: tach_group; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: coolant_needle; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
        NumberAnimation{
            target: fuel_needle; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
        }
    }
    Item{
        id: oiltempdisplay
        visible: if(root.oiltemphigh !== 0 ) true; else false
        opacity: 0;
        Image{
            x: 619; y: 168; z: 2
            source:  if(!root.sidelight) './soldat/oil_temp.png'; else './soldat/s_light/oil_temp.png'
        }
        Text{
            x: 622; y: 224
            height:24;width: 56
            text: getTemp("OIL")
            font.family: dESG7Italic.name
            font.italic: true
            font.pixelSize: 24
            horizontalAlignment: Text.AlignRight
            color: root.primary_color
            visible: if(root.oiltemp < root.oiltemphigh) true; else false

        }
        Text{
            x: 622; y: 224
            height:24;width: 56
            text: getTemp("OIL")
            font.family: dESG7Italic.name
            font.italic: true
            font.pixelSize: 24
            horizontalAlignment: Text.AlignRight
            color: root.primary_color
            visible: if(root.oiltemp >= root.oiltemphigh) true; else false;
            Timer{
                id: oiltemp_blink
                running:true
                interval: 100
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 100
                }
                else{
                    parent.opacity = 0
                } 
            }
        }
        Rectangle{
            width: 158; height: 18
            x: 622; y: 196
            z:5
            clip: true
            color: "#00000000"
            Image{
                source: './soldat/marker.png'
                x: if(root.oiltemp < 60)
                    -9   
                 else if(root.oiltemp < 140) 
                    ((root.oiltemp - 60) * 1.975) - 10
                 else 
                    149
                y:0;
            }
        }
        Timer{
            interval: 1000; running: root.ignition; repeat: false
            onTriggered: animateOilTemp.start()
        }
    }
    SequentialAnimation{
        id: animateOilTemp
        NumberAnimation{
            target: oiltempdisplay; property: "opacity"; from: 0.00; to: 1.00; duration:1000
        }
    }
    

    Item{
        id: oilpressuredisplay
        visible: if(root.oilpressurehigh !== 0 ) true; else false
        opacity: 0
        Image{
            x: 619; y: 74; z: 2
            source:  if(!root.sidelight) './soldat/oil_pressure.png'; else './soldat/s_light/oil_pressure.png'
        }
        Text{
            x: 622; y: 130
            height:24;width: 56
            text: root.oilpressure.toFixed(1)
            font.family: dESG7Italic.name
            font.italic: true
            font.pixelSize: 24
            horizontalAlignment: Text.AlignRight
            color: root.primary_color
            visible: true;
        }
        Rectangle{
            width: 158; height: 18
            x: 622; y: 102
            z:4
            clip: true
            color: "#00000000"
            Image{
                source: './soldat/marker.png'
                x: if(root.oilpressure.toFixed(1) < 10) (root.oilpressure.toFixed(1) * 15.7) - 9; else 149
                y:0;
                opacity: 1
            }
        }
        Timer{
            interval: 1500; running: root.ignition; repeat: false
            onTriggered: animateOilPressure.start()
        }
    }

    SequentialAnimation{
        id: animateOilPressure
        NumberAnimation{
            target: oilpressuredisplay; property: "opacity"; from: 0.00; to: 1.00; duration:1000
        }
    }
    

   

    Item{
        id: mileage_and_speed
        opacity: 0
        z: 5
        Item{
            z:5
            property string speedtext: if(root.peak_speed === 0 && root.rpm === 0) "PUSH_1P_START"; else "Peak_Speed_"+ getPeakSpeed() + "___Peak_RPM_" + root.peak_rpm
            property string spacing: "___"
            property string combined: speedtext + spacing
            property string display: combined.substring(step) + combined.substring(0, step)
            property int step: 0
            Timer {
                interval: 250
                running: true
                repeat: true
                onTriggered: parent.step = (parent.step + 1) % parent.combined.length
            }
            Text {
                id: speed_display_val
                font.pixelSize: 50
                horizontalAlignment: Text.AlignRight
                font.family: dESG7BoldItalic.name
                font.bold: true
                font.italic: true
                x: 459.8; y: 288.1
                width: 130.5
                height: 50.4
                z: 8
                color: root.primary_color
                clip: true
                text: if((root.speed === 0 && !root.car_movement && root.rpm === 0) || (root.speed === 0 && root.seatbelt)){
                        parent.display
                    }
                    else{
                        if (root.speedunits === 0) root.speed.toFixed(0); else (root.speed*.62).toFixed(0)
                    }
            }
        }
        Image{
            id: speed_label
            x: 560; y: 353; z: 5
            source: if(root.speedunits === 0) './soldat/kmh.png'; else './soldat/mph.png'

        }
        Text{
            id: mileage
            x: 489.1; y: 393.2; z:9
            width: 100; height: 18
            color: root.primary_color
            text: if (root.speedunits === 0)
                            (root.odometer/.62).toFixed(0) 
                        else if(root.speedunits === 1)
                            root.odometer 
                        else
                            root.odometer
            font.family: dESG7Italic.name
            font.italic: true
            font.pixelSize: 20
            horizontalAlignment: Text.AlignRight
            
        }
        Timer{
            interval: 2000; running: root.ignition; repeat: false
            onTriggered: animateMileage.start()
        }
        
    }
    SequentialAnimation{
            id: animateMileage
            NumberAnimation{
                target: mileage_and_speed; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
        }
    
    Item{ 
        id: coolant_system
        Image{
            id: coolant_bkg
            x: 24; y: 279; z: 1
            opacity: 0
            source: if(!root.sidelight) './soldat/coolant_bkg.png'; else './soldat/s_light/coolant_bkg.png';
            Timer{
                interval: 500; running: root.ignition; repeat: false
                onTriggered: animateCoolantBkg.start()
            }
        SequentialAnimation{
            id: animateCoolantBkg
            NumberAnimation{
                target: coolant_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
        }
        }
        Text{
            id: coolant_temp_txt
            x: 68; y: 413; z: 2
            opacity: 0
            width: 56
            color: root.primary_color
            text: getTemp("COOLANT")
            font.family: dESG7Italic.name
            font.italic: true
            font.pixelSize: 24
            horizontalAlignment: Text.AlignRight
            visible: if(root.watertemp < root.waterhigh) true; else false;
            Timer{
                interval: 1500; running: root.ignition; repeat: false
                onTriggered: animateCoolantNumber.start()
            }
            SequentialAnimation{
                id: animateCoolantNumber
                NumberAnimation{
                    target: coolant_temp_txt; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
                }
            }
        }
        Text{
            x: 68; y: 413; z: 2
            width: 56
            color: root.primary_color
            text: getTemp("COOLANT")
            font.family: dESG7Italic.name
            font.italic: true
            font.pixelSize: 24
            horizontalAlignment: Text.AlignRight
            visible: if(root.watertemp >= root.waterhigh) true; else false;
            Timer{
                id: coolant_blink
                running:true
                interval: 100
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 100
                }
                else{
                    parent.opacity = 0
                } 
            }
        }
        Image{
            id: coolant_needle
            opacity: 0;
            x: 35; y: 427; z: 4
            source: if(!root.sidelight) './soldat/orange_acc_needle.png'; else './soldat/acc_needle.png'
            transform:[
                Rotation {
                    id: coolant_rotate
                    origin.y: 7
                    origin.x: 144
                    angle:Math.min(Math.max(0, ((root.watertemp - 50) * 1.5)), 90)
                    }
            ]
            DropShadow{
                anchors.fill: coolant_needle
                horizontalOffset: 1
                verticalOffset: 1
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: coolant_needle
                z:3
            }
        }
    }
    Item{
        id: fuel_system
        Image{
            opacity: 0
            id: fuel_bkg
            x: 604; y: 279; z: 1
            source: if(!root.sidelight) './soldat/fuel_bkg.png'; else './soldat/s_light/fuel_bkg.png';
            Timer{ 
                interval: 500; running: root.ignition; repeat: false
                onTriggered: animateFuelBkg.start()
            }
        }
        SequentialAnimation{
            id: animateFuelBkg
            NumberAnimation{
                target: fuel_bkg; property: "opacity"; from: 0.00; to: 1.00; duration: 1000
            }
        }
        Image{
            id: fuel_needle
            x: 600; y: 427; z: 3
            opacity: 0;
            source: if(!root.sidelight) './soldat/orange_fuel_needle'; else './soldat/fuel_needle.png'
            transform:[
                Rotation {
                    id: fuel_rotate
                    origin.y: 7
                    origin.x: 20
                    angle:-Math.min(Math.max(0, ((root.fuel) * .9)), 90)
                    }
            ]
            DropShadow{
                anchors.fill: fuel_needle
                horizontalOffset: 1
                verticalOffset: 1
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: fuel_needle
                z:2
            }
        }
    }

     //Blinkers
    Image{
        x: 250; y:30; z:4
        source: if(!root.leftindicator) './soldat/left_signal_unlit.png'; else './soldat/left_signal_lit.png'
    }
    Image{
        x: 510; y:30; z:4
        source: if(!root.rightindicator) './soldat/right_signal_unlit.png'; else './soldat/right_signal_lit.png'
    }

    //Left Warnings
    Image{
        x: 23.3; y: 19; z: 4
        source: './soldat/warnings/brights.png'
        visible: root.mainbeam
    }
    Image{
        x: 70.6; y: 19; z: 4
        source: './soldat/warnings/sidelights.png'
        visible: root.sidelight
    }
    Image{
        x: 122.6; y: 17; z:4
        source: './soldat/warnings/seatbelt.png'
        visible: root.seatbelt
    }    
    Image{
        x: 150; y: 17; z: 4
        source: './soldat/warnings/battery.png'
        visible: root.battery
    }
     Image{
        x: 188; y: 21; z:4
        source: './soldat/warnings/abs.png'
        visible: root.abs
    }
    
    
    //Right Warnings
    Image{
        x: 556; y: 21; z:4
        source: './soldat/warnings/brake.png'
        visible: root.brake
    }
    Image{
        x: 616; y: 17; z:4
        source: './soldat/warnings/door.png'
        visible: root.doorswitch
    }
    Image{
        x: 649; y: 17; z: 4
        source: './soldat/warnings/checkengine.png'
        visible: root.mil
    }
    Image{
        x: 697; y: 18; z:4
        source: './soldat/warnings/oil.png'
        visible: root.oil
    }
    Image{
        x: 755; y: 17; z:4
        source: './soldat/warnings/srs.png'
        visible: root.airbag
    }
} //End Soldat Raggio Item



