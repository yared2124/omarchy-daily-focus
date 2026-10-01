/**
 * lib/Scheduler.js
 * Timeline parsing, deadline calculations, and goal schedule management.
 * Pure functions: highly testable, zero side-effects.
 */

/**
 * Checks if a goal belongs to the specified calendar date (local time).
 */
function isSameDay(date1, date2) {
  const d1 = new Date(date1);
  const d2 = new Date(date2);
  return (
    d1.getFullYear() === d2.getFullYear() &&
    d1.getMonth() === d2.getMonth() &&
    d1.getDate() === d2.getDate()
  );
}

/**
 * Filters goals scheduled for a specific date (defaults to current date).
 */
function getDailyGoals(dailyList = [], referenceDate = new Date()) {
  return dailyList.filter(goal => {
    if (!goal.scheduledStart && !goal.deadline) return true;
    const targetDate = goal.scheduledStart || goal.deadline;
    return isSameDay(targetDate, referenceDate);
  });
}

/**
 * Finds the currently active target, or the next upcoming pending target.
 */
function findActiveTarget(dailyList = [], referenceDate = new Date()) {
  const now = new Date(referenceDate).getTime();
  const todayGoals = getDailyGoals(dailyList, referenceDate);

  // 1. Look for an in-progress uncompleted goal: started <= now <= deadline
  const currentGoal = todayGoals.find(g => {
    if (g.completed) return false;
    const start = g.scheduledStart ? new Date(g.scheduledStart).getTime() : 0;
    const end = g.deadline ? new Date(g.deadline).getTime() : Infinity;
    return now >= start && now <= end;
  });

  if (currentGoal) {
    return { target: currentGoal, status: 'active' };
  }

  // 2. Next upcoming uncompleted goal today
  const upcomingGoals = todayGoals
    .filter(g => !g.completed)
    .sort((a, b) => {
      const timeA = new Date(a.scheduledStart || a.deadline).getTime();
      const timeB = new Date(b.scheduledStart || b.deadline).getTime();
      return timeA - timeB;
    });

  const nextGoal = upcomingGoals.find(g => {
    const start = new Date(g.scheduledStart || g.deadline).getTime();
    return start > now;
  });

  if (nextGoal) {
    return { target: nextGoal, status: 'upcoming' };
  }

  // 3. Fallback: Any remaining uncompleted goal (e.g. overdue or pending review)
  const remaining = upcomingGoals[0];
  if (remaining) {
    return { target: remaining, status: 'overdue' };
  }

  return { target: null, status: 'idle' };
}

/**
 * Calculates remaining time until a deadline.
 */
function calculateCountdown(deadline, referenceDate = new Date(), showSeconds = false) {
  if (!deadline) {
    return { remainingSeconds: 0, formatted: '--:--', isOverdue: false };
  }

  const now = new Date(referenceDate).getTime();
  const target = new Date(deadline).getTime();
  const diffMs = target - now;
  const isOverdue = diffMs < 0;
  const totalSeconds = Math.max(0, Math.floor(Math.abs(diffMs) / 1000));

  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  let formatted = '';
  if (hours > 0) {
    formatted = `${hours}h ${minutes}m`;
  } else if (minutes > 0) {
    formatted = showSeconds ? `${minutes}m ${seconds}s` : `${minutes}m`;
  } else {
    formatted = `${seconds}s`;
  }

  if (isOverdue && totalSeconds > 0) {
    formatted = `+${formatted}`;
  }

  return {
    remainingSeconds: diffMs > 0 ? totalSeconds : 0,
    formatted,
    isOverdue
  };
}

/**
 * Calculates daily progress score and completion percentage.
 */
function calculateProgress(dailyList = [], referenceDate = new Date()) {
  const todayGoals = getDailyGoals(dailyList, referenceDate);
  const total = todayGoals.length;
  if (total === 0) {
    return {
      completed: 0,
      total: 0,
      percentage: 0,
      formatted: '0/0 DONE'
    };
  }

  const completed = todayGoals.filter(g => g.completed).length;
  const percentage = Math.round((completed / total) * 100);

  return {
    completed,
    total,
    percentage,
    formatted: `${completed}/${total} DONE`
  };
}

/**
 * Identifies goals whose deadlines passed while the system was away or asleep.
 */
function detectMissedTargets(dailyList = [], lastCheckTime, currentTime = new Date()) {
  if (!lastCheckTime) return [];
  const start = new Date(lastCheckTime).getTime();
  const end = new Date(currentTime).getTime();

  return dailyList.filter(g => {
    if (g.completed) return false;
    if (!g.deadline) return false;
    const deadline = new Date(g.deadline).getTime();
    return deadline > start && deadline <= end;
  });
}

const Scheduler = {
  isSameDay,
  getDailyGoals,
  findActiveTarget,
  calculateCountdown,
  calculateProgress,
  detectMissedTargets
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = Scheduler;
}
