import QtQuick 2.15
import QtQuick.Layouts 1.15

/**
 * components/GoalRow.qml
 * Interactive goal row for the planner panel (NestJS theme):
 * - One-click completion checkbox with strike-through animation.
 * - Priority badge (High, Normal, Low) in NestJS color scheme.
 * - Deadline / Schedule timestamp badge.
 * - Delete button.
 */
Rectangle {
    id: root

    property var goalData: ({})
    property bool isCompleted: goalData ? Boolean(goalData.completed) : false
    property string title: goalData ? (goalData.title || "") : ""
    property string priority: goalData ? (goalData.priority || "normal") : "normal"
    property string deadline: goalData ? (goalData.deadline || "") : ""

    signal toggleCompleted(string goalId)
    signal deleteGoal(string goalId)

    implicitWidth: 380
    implicitHeight: 48
    radius: 8
    color: mouseArea.containsMouse ? "#222436" : "#181a24"
    border.color: root.isCompleted ? "#2a2d3f" : (mouseArea.containsMouse ? "#3d4059" : "#2a2d3f")
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Checkbox button
        Rectangle {
            id: checkbox
            width: 20
            height: 20
            radius: 5
            color: root.isCompleted ? "#10b981" : "transparent"
            border.color: root.isCompleted ? "#10b981" : (checkboxMouse.containsMouse ? "#e0234e" : "#64748b")
            border.width: 2

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 12
                font.bold: true
                color: "#ffffff"
                visible: root.isCompleted
            }

            MouseArea {
                id: checkboxMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.goalData && root.goalData.id) {
                        root.toggleCompleted(root.goalData.id);
                    }
                }
            }
        }

        // Title and Info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: root.isCompleted ? "#64748b" : "#ffffff"
                font.pixelSize: 13
                font.bold: true
                font.strikeout: root.isCompleted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6

                // Priority Badge (NestJS Colors: High = Nest Red #e0234e, Normal = Amber #f59e0b, Low = Sky #38bdf8)
                Rectangle {
                    implicitWidth: priorityText.implicitWidth + 8
                    implicitHeight: 16
                    radius: 4
                    color: root.priority === "high" ? "#e0234e" : (root.priority === "low" ? "#38bdf8" : "#f59e0b")
                    opacity: root.isCompleted ? 0.4 : 0.9

                    Text {
                        id: priorityText
                        anchors.centerIn: parent
                        text: root.priority.toUpperCase()
                        font.pixelSize: 9
                        font.bold: true
                        color: root.priority === "high" ? "#ffffff" : "#12131a"
                    }
                }

                // Deadline text
                Text {
                    text: root.deadline ? root.deadline.substring(11, 16) : ""
                    color: "#94a3b8"
                    font.pixelSize: 11
                    font.family: "monospace"
                    visible: root.deadline !== ""
                }
            }
        }

        // Delete button
        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: deleteMouse.containsMouse ? "#e0234e" : "transparent"
            opacity: deleteMouse.containsMouse ? 1.0 : (mouseArea.containsMouse ? 0.6 : 0.0)

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 11
                color: deleteMouse.containsMouse ? "#ffffff" : "#94a3b8"
            }

            MouseArea {
                id: deleteMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.goalData && root.goalData.id) {
                        root.deleteGoal(root.goalData.id);
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // allows child mouse areas to handle clicks
    }
}
