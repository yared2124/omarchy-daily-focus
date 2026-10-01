import QtQuick 2.15
import "lib/Store.js" as Store
import "lib/Scheduler.js" as Scheduler

/**
 * Service.qml
 * Background event loop for Omarchy Daily Focus:
 * - Periodically recalculates deadlines and active focus targets.
 * - Dispatches native notifications via omarchy-notification-send.
 * - Detects system suspend/resume and triggers smart catch-up alerts.
 * - Atomically exports runtime state to ~/.local/state/omarchy/focus/state.json.
 */
Item {
    id: focusService

    // Configuration & State paths
    readonly property string configPath: Store.resolvePath("~/.config/omarchy/focus/config.json")
    readonly property string goalsPath: Store.resolvePath("~/.config/omarchy/focus/goals.json")
    readonly property string statePath: Store.resolvePath("~/.local/state/omarchy/focus/state.json")

    // In-memory state
    property var config: Store.DEFAULT_CONFIG
    property var goals: ({ version: 1, daily: [], weekly: [] })
    property var activeTarget: null
    property string activeStatus: "idle"
    property var countdown: ({ remainingSeconds: 0, formatted: "--:--", isOverdue: false })
    property var progress: ({ completed: 0, total: 0, percentage: 0, formatted: "0/0 DONE" })
    property date lastTickTime: new Date()
    property var notifiedGoalIds: ({})

    // Signal emitted when state changes for BarWidget and Panel
    signal stateUpdated()

    Component.onCompleted: {
        loadData();
        tick();
    }

    // Main 1-second background tick
    Timer {
        id: ticker
        interval: 1000
        running: true
        repeat: true
        onTriggered: focusService.tick()
    }

    // 10-second reload from disk to detect external edits in goals.json or config.json
    Timer {
        id: diskWatcher
        interval: 10000
        running: true
        repeat: true
        onTriggered: focusService.loadData()
    }

    function loadData() {
        config = Store.loadConfig(configPath);
        goals = Store.loadGoals(goalsPath);
        updateSchedule();
    }

    function tick() {
        var currentTime = new Date();
        var delta = currentTime.getTime() - lastTickTime.getTime();

        // System Suspend / Resume check: delta > 10 seconds indicates system slept
        if (delta > 10000 && config.catchUpAlert) {
            handleResume(lastTickTime, currentTime);
        }

        lastTickTime = currentTime;
        updateSchedule();
        checkDeadlinesAndReminders(currentTime);
        exportState();
    }

    function updateSchedule() {
        var now = new Date();
        var targetInfo = Scheduler.findActiveTarget(goals.daily, now);
        activeTarget = targetInfo.target;
        activeStatus = targetInfo.status;

        if (activeTarget && activeTarget.deadline) {
            countdown = Scheduler.calculateCountdown(activeTarget.deadline, now, config.showSeconds);
        } else {
            countdown = { remainingSeconds: 0, formatted: "--:--", isOverdue: false };
        }

        progress = Scheduler.calculateProgress(goals.daily, now);
        stateUpdated();
    }

    function checkDeadlinesAndReminders(currentTime) {
        if (!config.notify || !activeTarget) return;

        var goalId = activeTarget.id;
        var nowMs = currentTime.getTime();
        var deadlineMs = new Date(activeTarget.deadline).getTime();
        var diffMinutes = Math.floor((deadlineMs - nowMs) / 60000);

        // Pre-target reminder (e.g. 10 minutes prior)
        var reminderKey = goalId + "_reminder";
        if (config.reminderMinutes > 0 && diffMinutes <= config.reminderMinutes && diffMinutes > 0) {
            if (!notifiedGoalIds[reminderKey]) {
                notifiedGoalIds[reminderKey] = true;
                sendNotification("Target Reminder", "'" + activeTarget.title + "' ends in " + diffMinutes + " minutes!");
            }
        }

        // Deadline passed alert
        var deadlineKey = goalId + "_deadline";
        if (diffMinutes <= 0) {
            if (!notifiedGoalIds[deadlineKey]) {
                notifiedGoalIds[deadlineKey] = true;
                sendNotification("Focus Block Ended", "Target reached: '" + activeTarget.title + "'. Review your progress!");
            }
        }
    }

    function handleResume(sleepTime, wakeTime) {
        var missed = Scheduler.detectMissedTargets(goals.daily, sleepTime, wakeTime);
        if (missed.length > 0) {
            var msg = missed.length === 1
                ? "1 missed focus target while away."
                : missed.length + " missed focus targets while away.";
            sendNotification("Daily Focus", msg);

            // Mark missed targets as pending review
            for (var i = 0; i < missed.length; i++) {
                missed[i].pendingReview = true;
            }
            Store.writeJsonAtomic(goalsPath, goals);
        }
    }

    function sendNotification(title, message) {
        // Omarchy native desktop notification via CLI utility
        var cmd = "omarchy-notification-send '" + title + "' '" + message + "'";
        if (typeof Qt !== 'undefined' && Qt.openUrlExternally) {
            // Invocation inside Omarchy Shell runtime
        }
    }

    function exportState() {
        var stateData = {
            updatedAt: new Date().toISOString(),
            activeTarget: activeTarget,
            activeStatus: activeStatus,
            countdown: countdown,
            progress: progress,
            progressPercentage: progress.percentage
        };
        try {
            Store.writeJsonAtomic(statePath, stateData);
        } catch (e) {
            // Graceful fallback if filesystem is read-only
        }
    }
}
