import QtQuick 2.15
import QtQuick.Layouts 1.15

/**
 * components/GoalRow.qml
 * Interactive goal row for the planner panel:
 * - One-click completion checkbox with strike-through animation.
 * - Priority badge (High, Normal, Low).
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
    color: mouseArea.containsMouse ? "#313244" : "#181825"
    border.color: root.isCompleted ? "#45475a" : (mouseArea.containsMouse ? "#585b70" : "#313244")
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
            color: root.isCompleted ? "#a6e3a1" : "transparent"
            border.color: root.isCompleted ? "#a6e3a1" : "#6c7086"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 12
                font.bold: true
                color: "#11111b"
                visible: root.isCompleted
            }

            MouseArea {
                anchors.fill: parent
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
                color: root.isCompleted ? "#6c7086" : "#cdd6f4"
                font.pixelSize: 13
                font.bold: true
                font.strikeout: root.isCompleted
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6

                // Priority Badge
                Rectangle {
                    implicitWidth: priorityText.implicitWidth + 8
                    implicitHeight: 16
                    radius: 4
                    color: root.priority === "high" ? "#f38ba8" : (root.priority === "low" ? "#89b4fa" : "#f9e2af")
                    opacity: root.isCompleted ? 0.4 : 0.9

                    Text {
                        id: priorityText
                        anchors.centerIn: parent
                        text: root.priority.toUpperCase()
                        font.pixelSize: 9
                        font.bold: true
                        color: "#11111b"
                    }
                }

                // Deadline text
                Text {
                    text: root.deadline ? root.deadline.substring(11, 16) : ""
                    color: "#a6adc8"
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
            color: deleteMouse.containsMouse ? "#f38ba8" : "transparent"
            opacity: deleteMouse.containsMouse ? 1.0 : (mouseArea.containsMouse ? 0.6 : 0.0)

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 11
                color: deleteMouse.containsMouse ? "#11111b" : "#a6adc8"
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
