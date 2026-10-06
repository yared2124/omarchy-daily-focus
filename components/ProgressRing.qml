import QtQuick 2.15

/**
 * components/ProgressRing.qml
 * Clean, lightweight canvas-based radial progress ring (NestJS theme).
 * Smoothly animates when progress percentage updates.
 */
Item {
    id: root

    property real percentage: 0
    property real strokeWidth: 3.0
    property color ringColor: "#e0234e"
    property color trackColor: "rgba(255, 255, 255, 0.10)"
    property string label: ""
    property color textColor: "#ffffff"

    implicitWidth: 32
    implicitHeight: 32

    Behavior on percentage {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutCubic
        }
    }

    onPercentageChanged: canvas.requestPaint()
    onRingColorChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centreX = width / 2;
            var centreY = height / 2;
            var radius = (Math.min(width, height) - root.strokeWidth) / 2;

            if (radius <= 0) return;

            // 1. Background Track Ring
            ctx.beginPath();
            ctx.strokeStyle = root.trackColor;
            ctx.lineWidth = root.strokeWidth;
            ctx.arc(centreX, centreY, radius, 0, 2 * Math.PI, false);
            ctx.stroke();

            // 2. Active Progress Arc (-90 deg start = top of circle)
            var startAngle = -Math.PI / 2;
            var progressAngle = (Math.min(100, Math.max(0, root.percentage)) / 100) * 2 * Math.PI;

            if (progressAngle > 0) {
                ctx.beginPath();
                ctx.strokeStyle = root.ringColor;
                ctx.lineWidth = root.strokeWidth;
                ctx.lineCap = "round";
                ctx.arc(centreX, centreY, radius, startAngle, startAngle + progressAngle, false);
                ctx.stroke();
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.label !== ""
        text: root.label
        color: root.textColor
        font.pixelSize: Math.max(8, root.height * 0.28)
        font.bold: true
    }
}
