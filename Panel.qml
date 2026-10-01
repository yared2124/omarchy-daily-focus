import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components" as Components
import "lib/Store.js" as Store
import "lib/Scheduler.js" as Scheduler

/**
 * Panel.qml
 * Full interactive planner panel:
 * - Week-at-a-glance overview & real-time statistics.
 * - Daily goal backlog with one-click completion toggles.
 * - Quick goal entry form (title, priority, time).
 * - Immediate atomic sync with ~/.config/omarchy/focus/goals.json.
 */
Rectangle {
    id: root

    implicitWidth: 440
    implicitHeight: 600
    radius: 12
    color: "#1e1e2e"
    border.color: "#313244"
    border.width: 1

    property var service: null
    property string goalsPath: Store.resolvePath("~/.config/omarchy/focus/goals.json")
    property var goalsData: ({ version: 1, daily: [], weekly: [] })

    signal closed()

    Component.onCompleted: loadGoals()

    function loadGoals() {
        goalsData = Store.loadGoals(goalsPath);
        dailyModel.clear();
        for (var i = 0; i < goalsData.daily.length; i++) {
            dailyModel.append(goalsData.daily[i]);
        }
    }

    function saveGoals() {
        var dailyList = [];
        for (var i = 0; i < dailyModel.count; i++) {
            dailyList.push(dailyModel.get(i));
        }
        goalsData.daily = dailyList;
        Store.writeJsonAtomic(goalsPath, goalsData);

        if (root.service && root.service.loadData) {
            root.service.loadData();
        }
    }

    function addGoal(title, priority) {
        if (!title || title.trim() === "") return;

        var now = new Date();
        var deadline = new Date(now.getTime() + 60 * 60 * 1000); // 1 hour default

        var newGoal = {
            id: "goal-" + Date.now(),
            title: title.trim(),
            scheduledStart: now.toISOString(),
            deadline: deadline.toISOString(),
            completed: false,
            priority: priority || "normal",
            tags: [],
            pendingReview: false
        };

        dailyModel.insert(0, newGoal);
        saveGoals();
    }

    function toggleGoal(goalId) {
        for (var i = 0; i < dailyModel.count; i++) {
            var item = dailyModel.get(i);
            if (item.id === goalId) {
                dailyModel.setProperty(i, "completed", !item.completed);
                saveGoals();
                break;
            }
        }
    }

    function deleteGoal(goalId) {
        for (var i = 0; i < dailyModel.count; i++) {
            if (dailyModel.get(i).id === goalId) {
                dailyModel.remove(i);
                saveGoals();
                break;
            }
        }
    }

    ListModel {
        id: dailyModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // 1. Header Row
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "🎯 Daily Focus Planner"
                color: "#cdd6f4"
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
            }

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMouse.containsMouse ? "#313244" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "#a6adc8"
                    font.pixelSize: 13
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closed()
                }
            }
        }

        // 2. Stats Bar
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 8
            color: "#181825"
            border.color: "#313244"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Components.ProgressRing {
                    width: 36
                    height: 36
                    strokeWidth: 3.5
                    percentage: {
                        var total = dailyModel.count;
                        if (total === 0) return 0;
                        var done = 0;
                        for (var i = 0; i < total; i++) {
                            if (dailyModel.get(i).completed) done++;
                        }
                        return Math.round((done / total) * 100);
                    }
                    ringColor: "#a6e3a1"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Today's Target Progress"
                        color: "#a6adc8"
                        font.pixelSize: 11
                    }

                    Text {
                        text: {
                            var total = dailyModel.count;
                            var done = 0;
                            for (var i = 0; i < total; i++) {
                                if (dailyModel.get(i).completed) done++;
                            }
                            return done + " of " + total + " completed (" + (total > 0 ? Math.round((done / total) * 100) : 0) + "%)";
                        }
                        color: "#cdd6f4"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }
            }
        }

        // 3. Add Goal Input Form
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 6
                color: "#181825"
                border.color: goalInput.activeFocus ? "#89b4fa" : "#313244"
                border.width: 1

                TextInput {
                    id: goalInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    selectByMouse: true

                    Text {
                        text: "Add a new focus goal..."
                        color: "#6c7086"
                        font.pixelSize: 13
                        visible: !goalInput.text && !goalInput.activeFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onAccepted: {
                        root.addGoal(goalInput.text, priorityCombo.currentText.toLowerCase());
                        goalInput.text = "";
                    }
                }
            }

            ComboBox {
                id: priorityCombo
                implicitWidth: 90
                implicitHeight: 38
                model: ["Normal", "High", "Low"]
            }

            Rectangle {
                width: 38
                height: 38
                radius: 6
                color: addMouse.containsMouse ? "#b4befe" : "#89b4fa"

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#11111b"
                }

                MouseArea {
                    id: addMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.addGoal(goalInput.text, priorityCombo.currentText.toLowerCase());
                        goalInput.text = "";
                    }
                }
            }
        }

        // 4. Daily Goals ListView
        ListView {
            id: goalsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: dailyModel

            delegate: Components.GoalRow {
                width: goalsListView.width
                goalData: model
                onToggleCompleted: root.toggleGoal(goalId)
                onDeleteGoal: root.deleteGoal(goalId)
            }

            // Empty state placeholder
            Text {
                anchors.centerIn: parent
                text: "No goals scheduled yet.\nAdd a target above or edit goals.json!"
                horizontalAlignment: Text.AlignHCenter
                color: "#6c7086"
                font.pixelSize: 13
                visible: dailyModel.count === 0
            }
        }
    }
}
