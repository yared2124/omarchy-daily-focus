const assert = require('assert');
const path = require('path');
const fs = require('fs');
const Scheduler = require('../lib/Scheduler');
const Store = require('../lib/Store');

console.log('🧪 Running Omarchy Daily Focus unit tests in Docker...\n');

// 1. Store: validateGoals
{
  const empty = Store.validateGoals({});
  assert.strictEqual(empty.valid, true);
  assert.deepStrictEqual(empty.data.daily, []);
  assert.deepStrictEqual(empty.data.weekly, []);

  const sample = Store.validateGoals({
    daily: [{ title: 'Write tests', completed: true }]
  });
  assert.strictEqual(sample.data.daily[0].title, 'Write tests');
  assert.strictEqual(sample.data.daily[0].completed, true);
  console.log('✓ Store.validateGoals passed');
}

// 2. Store: Atomic Write & Read
{
  const tmpFile = path.join(__dirname, 'test-state.tmp.json');
  try {
    const testData = { hello: 'omarchy', timestamp: Date.now() };
    Store.writeJsonAtomic(tmpFile, testData);
    const readBack = Store.readJson(tmpFile);
    assert.strictEqual(readBack.hello, 'omarchy');
    console.log('✓ Store.writeJsonAtomic & readJson passed');
  } finally {
    if (fs.existsSync(tmpFile)) fs.unlinkSync(tmpFile);
  }
}

// 3. Scheduler: calculateProgress
{
  const now = new Date('2026-10-01T10:00:00Z');
  const goals = [
    { id: '1', deadline: '2026-10-01T11:00:00Z', completed: true },
    { id: '2', deadline: '2026-10-01T12:00:00Z', completed: true },
    { id: '3', deadline: '2026-10-01T15:00:00Z', completed: false }
  ];
  const progress = Scheduler.calculateProgress(goals, now);
  assert.strictEqual(progress.completed, 2);
  assert.strictEqual(progress.total, 3);
  assert.strictEqual(progress.percentage, 67);
  assert.strictEqual(progress.formatted, '2/3 DONE');
  console.log('✓ Scheduler.calculateProgress passed');
}

// 4. Scheduler: calculateCountdown
{
  const now = new Date('2026-10-01T10:00:00Z');
  const deadline = new Date('2026-10-01T10:25:00Z');
  const countdown = Scheduler.calculateCountdown(deadline, now, false);
  assert.strictEqual(countdown.formatted, '25m');
  assert.strictEqual(countdown.isOverdue, false);

  const overdue = Scheduler.calculateCountdown(new Date('2026-10-01T09:30:00Z'), now, false);
  assert.strictEqual(overdue.isOverdue, true);
  assert.strictEqual(overdue.formatted, '+30m');
  console.log('✓ Scheduler.calculateCountdown passed');
}

// 5. Scheduler: findActiveTarget
{
  const now = new Date('2026-10-01T10:30:00Z');
  const goals = [
    {
      id: 'g1',
      title: 'Current Focus',
      scheduledStart: '2026-10-01T10:00:00Z',
      deadline: '2026-10-01T11:00:00Z',
      completed: false
    },
    {
      id: 'g2',
      title: 'Upcoming Focus',
      scheduledStart: '2026-10-01T14:00:00Z',
      deadline: '2026-10-01T15:00:00Z',
      completed: false
    }
  ];

  const result = Scheduler.findActiveTarget(goals, now);
  assert.strictEqual(result.status, 'active');
  assert.strictEqual(result.target.title, 'Current Focus');
  console.log('✓ Scheduler.findActiveTarget passed');
}

// 6. Scheduler: detectMissedTargets (Catch-up on Resume)
{
  const sleepTime = new Date('2026-10-01T08:00:00Z');
  const wakeTime = new Date('2026-10-01T12:00:00Z');
  const goals = [
    {
      id: 'missed1',
      title: 'Missed Task',
      deadline: '2026-10-01T09:30:00Z',
      completed: false
    },
    {
      id: 'future',
      title: 'Future Task',
      deadline: '2026-10-01T15:00:00Z',
      completed: false
    }
  ];

  const missed = Scheduler.detectMissedTargets(goals, sleepTime, wakeTime);
  assert.strictEqual(missed.length, 1);
  assert.strictEqual(missed[0].id, 'missed1');
  console.log('✓ Scheduler.detectMissedTargets (Catch-up on Resume) passed');
}

console.log('\n🎉 ALL TESTS PASSED SUCCESSFULLY IN DOCKER!');
