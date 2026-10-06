import QtQuick 2.15
import QtQuick.Layouts 1.15
import "components" as Components
import "lib/Store.js" as Store
import "lib/Scheduler.js" as Scheduler

/**
 * BarWidget.qml
 * The bar pill widget rendered in the Omarchy top bar (NestJS theme):
 * - Left: Active focus target title & ticking countdown towards deadline.
 * - Right: Radial progress ring with completion score (e.g., 5/8 DONE).
 * - Click action: Toggles the goal planner panel.
 */
Rectangle {
    id: root

    // Sizing & Theme defaults (NestJS Palette)
    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: 30
    radius: height / 2
    color: mouseArea.containsMouse ? "#222436" : "#181a24"
    border.color: mouseArea.containsMouse ? "#e0234e" : "#2a2d3f"
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // Service binding or fallback local state
    property var service: null
    property var config: service ? service.config : Store.DEFAULT_CONFIG
    property var activeTarget: service ? service.activeTarget : null
    property var countdown: service ? service.countdown : ({ formatted: "--:--", isOverdue: false })
    property var progress: service ? service.progress : ({ completed: 0, total: 0, percentage: 0, formatted: "0/0 DONE" })
    property string barMode: config.barMode || "both"

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        // Icon indicator
        Text {
            text: "🎯"
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter
        }

        // Left Section: Target Title & Countdown
        RowLayout {
            id: countdownSection
            spacing: 6
            visible: root.barMode === "both" || root.barMode === "countdown"
            Layout.alignment: Qt.AlignVCenter

            Text {
                id: targetTitle
                text: root.activeTarget ? root.activeTarget.title : "No active focus"
                color: root.activeTarget ? "#ffffff" : "#94a3b8"
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
                Layout.maximumWidth: 140
            }

            Rectangle {
                width: 1
                height: 12
                color: "#2a2d3f"
                visible: root.activeTarget !== null
            }

            Text {
                id: countdownText
                text: root.countdown.formatted
                color: root.countdown.isOverdue ? "#e0234e" : "#10b981"
                font.pixelSize: 12
                font.family: "monospace"
                font.bold: true
                visible: root.activeTarget !== null
            }
        }

        // Separator between countdown and ring
        Rectangle {
            width: 1
            height: 14
            color: "#2a2d3f"
            visible: root.barMode === "both"
        }

        // Right Section: Radial Progress Ring
        RowLayout {
            id: progressSection
            spacing: 6
            visible: root.barMode === "both" || root.barMode === "progress"
            Layout.alignment: Qt.AlignVCenter

            Components.ProgressRing {
                width: 18
                height: 18
                strokeWidth: 2.5
                percentage: root.progress.percentage
                ringColor: root.progress.percentage >= 100 ? "#10b981" : "#e0234e"
                trackColor: "#1affffff"
            }

            Text {
                text: root.progress.completed + "/" + root.progress.total
                color: "#ffffff"
                font.pixelSize: 11
                font.bold: true
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // Signal Omarchy shell to toggle the planner panel
            if (typeof omarchy !== 'undefined' && omarchy.togglePanel) {
                omarchy.togglePanel("daily.focus");
            }
        }
    }
}
