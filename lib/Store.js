/**
 * lib/Store.js
 * Handles reading, validating, and atomically persisting goals and configurations.
 * Designed to work seamlessly in both Node.js (testing/CLI) and QML runtimes.
 */

const fs = (typeof require !== 'undefined') ? require('fs') : null;
const path = (typeof require !== 'undefined') ? require('path') : null;
const os = (typeof require !== 'undefined') ? require('os') : null;

const DEFAULT_CONFIG = {
  barMode: "both",
  showSeconds: false,
  notify: true,
  reminderMinutes: 10,
  catchUpAlert: true,
  weekStart: "monday",
  workHours: {
    start: "08:00",
    end: "20:00"
  }
};

/**
 * Resolves ~ to the user's home directory.
 */
function resolvePath(filePath) {
  if (!filePath) return '';
  if (filePath.startsWith('~')) {
    const home = (typeof process !== 'undefined' && process.env && process.env.HOME)
      ? process.env.HOME
      : ((typeof os !== 'undefined' && os && os.homedir) ? os.homedir() : '');
    return filePath.replace(/^~/, home);
  }
  return filePath;
}

/**
 * Validates goals schema. Ensures it has version and valid daily/weekly arrays.
 */
function validateGoals(data) {
  if (!data || typeof data !== 'object') {
    return { valid: false, error: 'Goals data must be a JSON object' };
  }
  if (!Array.isArray(data.daily)) {
    data.daily = [];
  }
  if (!Array.isArray(data.weekly)) {
    data.weekly = [];
  }
  if (!data.version) {
    data.version = 1;
  }

  // Sanitize daily goals
  data.daily = data.daily.map((g, idx) => ({
    id: g.id || `goal-${Date.now()}-${idx}`,
    title: String(g.title || 'Untitled Goal').trim(),
    scheduledStart: g.scheduledStart || new Date().toISOString(),
    deadline: g.deadline || new Date().toISOString(),
    completed: Boolean(g.completed),
    priority: ['low', 'normal', 'high'].includes(g.priority) ? g.priority : 'normal',
    tags: Array.isArray(g.tags) ? g.tags : [],
    pendingReview: Boolean(g.pendingReview)
  }));

  return { valid: true, data };
}

/**
 * Reads and parses JSON safely. Returns fallback if file does not exist or has invalid JSON.
 */
function readJson(filePath, fallback = {}) {
  if (!fs) return fallback;
  const absPath = resolvePath(filePath);
  try {
    if (!fs.existsSync(absPath)) {
      return fallback;
    }
    const raw = fs.readFileSync(absPath, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    console.error(`[Store] Error reading ${absPath}:`, err.message);
    return fallback;
  }
}

/**
 * Writes JSON atomically using a temp file rename to prevent half-written reads.
 */
function writeJsonAtomic(filePath, data) {
  if (!fs || !path) {
    throw new Error('Filesystem access not available in current environment');
  }
  const absPath = resolvePath(filePath);
  const dir = path.dirname(absPath);

  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  const tempFile = `${absPath}.tmp.${Date.now()}`;
  const content = JSON.stringify(data, null, 2);

  fs.writeFileSync(tempFile, content, 'utf8');
  fs.renameSync(tempFile, absPath);
  return true;
}

/**
 * Loads configuration with fallback to defaults.
 */
function loadConfig(configPath) {
  const loaded = readJson(configPath, {});
  return Object.assign({}, DEFAULT_CONFIG, loaded);
}

/**
 * Loads goals with automatic schema validation and fallback.
 */
function loadGoals(goalsPath) {
  const raw = readJson(goalsPath, { version: 1, daily: [], weekly: [] });
  const result = validateGoals(raw);
  return result.data;
}

const Store = {
  DEFAULT_CONFIG,
  resolvePath,
  validateGoals,
  readJson,
  writeJsonAtomic,
  loadConfig,
  loadGoals
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = Store;
}
