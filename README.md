# 🎯 Omarchy Daily Focus (`daily.focus`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Omarchy Shell](https://img.shields.io/badge/Omarchy-Plugin-blueviolet.svg)](#requirements)
[![Privacy: 100% Offline](https://img.shields.io/badge/Privacy-100%25%20Offline-success.svg)](#privacy--architecture)

**Daily and weekly goals directly inside your Omarchy bar, featuring live target countdowns and one-click progress tracking.**

---

The bar pill displays your active focus task with a real-time ticking countdown alongside a radial progress ring tracking your daily targets. Clicking the pill slides open the planner: a week-at-a-glance timeline, a daily backlog with one-click completion toggles, and real-time statistics comparing planned work against finished goals.

---

## ✨ Features

- **Bar Pill Integration**: Shows active task countdown + circular progress ring (e.g., `5/8 DONE`).
- **Interactive Planner Panel**: Week-at-a-glance timeline, milestone check-offs, and goal creator.
- **Hybrid Storage & Hot-Reload**: Manage goals via GUI or directly in `~/.config/omarchy/focus/goals.json`. Atomic writes prevent corrupted state across threads.
- **Smart Suspend/Resume Catch-up**: Avoid notification floods when waking your machine; aggregates missed targets cleanly.
- **Desktop Alerts**: Gentle native alerts via `omarchy-notification-send` at deadline or with custom pre-warnings (e.g. 10m before).
- **Comprehensive CLI**: Query status, list targets, or toggle the planner from terminal scripts or tmux.
- **Hyprland Keybind Ready**: Native integration with Omarchy's Lua keybindings.
- **100% Offline**: Zero telemetry, no external network calls, completely local.

---

## 📦 Installation

Install via the Omarchy plugin manager:

```bash
omarchy plugin add https://github.com/yared2124/omarchy-daily-focus.git --enable
```

Pick a bar section when prompted, or place it yourself afterwards:

```bash
omarchy bar move daily.focus --section center
```

On first run, the pill displays your pending targets. Click it to open the panel and create your first goal, or populate your schedule via `goals.json`.

---

## 🔄 Updating

```bash
omarchy plugin update daily.focus
omarchy restart shell
```

> **Note**: `omarchy plugin update` pulls the latest changes from `main`, displays the diff, and fast-forwards once confirmed (`--yes` skips the prompt). Restarting the shell clears the cached QML bytecode and applies hot reload.

---

## ⚙️ How It Works

### 1. Hybrid Goal Management
Goals can be edited seamlessly through either interface:
- **The Panel UI**: Click the bar pill to open your schedule, check off completed milestones, or add new goals via the form.
- **Plain JSON**: Directly modify `~/.config/omarchy/focus/goals.json`. The engine watches the file and hot-reloads state as soon as you save in your editor. Every disk write replaces state files atomically (`rename`-based), preventing half-written reads.

#### Sample `goals.json`
```json
{
  "version": 1,
  "daily": [
    {
      "id": "goal-001",
      "title": "Complete Church ERP API docs",
      "scheduledStart": "2026-10-01T09:00:00+03:00",
      "deadline": "2026-10-01T11:30:00+03:00",
      "completed": false,
      "priority": "high",
      "tags": ["work", "docs"]
    },
    {
      "id": "goal-002",
      "title": "Review GitHub Actions CI run",
      "scheduledStart": "2026-10-01T14:00:00+03:00",
      "deadline": "2026-10-01T15:00:00+03:00",
      "completed": true,
      "priority": "normal",
      "tags": ["ci"]
    }
  ],
  "weekly": [
    {
      "id": "week-001",
      "title": "Ship v1.2 release",
      "targetDate": "2026-10-04",
      "progress": 60
    }
  ]
}
```

---

### 2. The Bar Pill Layout
The pill renders your current objective alongside your cumulative day score:
- **Left**: Active target title and a ticking countdown towards its deadline.
- **Right**: A clean radial ring with completed vs. total daily targets (e.g. `5/8 DONE`).

---

### 3. Catch-up on Resume
If your machine was suspended while a goal's scheduled time passed, the plugin suppresses outdated alert banners. When the machine wakes:
1. A single aggregated alert is displayed: `1 missed focus target while away.`
2. The panel marks that target as **Pending Review** so you can mark it complete or reschedule without distorting your focus streak metrics.

---

## 💻 Command Line Interface

Query your goals and control the panel directly from your terminal or scripts:

```bash
omarchy-shell daily.focus today      # Print full-day target table
omarchy-shell daily.focus next       # Show current target & remaining time
omarchy-shell daily.focus list       # List active weekly goals
omarchy-shell daily.focus toggle     # Toggle the planner panel
omarchy-shell daily.focus settings   # Jump straight to settings view
```

### Scripting & Status-Bar Export
The daily plan and progress state are exported to:
```
~/.local/state/omarchy/focus/state.json
```
This file provides raw ISO timestamps and completion booleans for status-bar scripts (Waybar, eww) and terminal dashboards:

```bash
# Example: Read current progress percentage using jq
jq '.progressPercentage' ~/.local/state/omarchy/focus/state.json
```

---

## ⌨️ Hyprland Binds

Omarchy manages Hyprland bindings via Lua. Add these shortcuts to `~/.config/hypr/bindings.lua`:

```lua
-- Toggle goal planner panel
o.bind("SUPER + G", "Goal planner", "omarchy-shell daily.focus toggle")

-- Quick open settings
o.bind("SUPER + SHIFT + G", "Goal settings", "omarchy-shell daily.focus settings")
```

Check for collisions before binding:
```bash
omarchy menu keybindings --print | grep -i "SUPER + G"
```

---

## 🛠️ Configuration

Settings are stored in `~/.config/omarchy/focus/config.json`. The shell reloads changes immediately upon saving:

```json
{
  "barMode": "both",
  "showSeconds": false,
  "notify": true,
  "reminderMinutes": 10,
  "catchUpAlert": true,
  "weekStart": "monday",
  "workHours": {
    "start": "08:00",
    "end": "20:00"
  }
}
```

### Configuration Options

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `barMode` | `string` | `"both"` | Display mode: `"both"` (countdown + ring), `"countdown"`, or `"progress"`. |
| `showSeconds` | `boolean` | `false` | Include seconds in bar countdown. |
| `notify` | `boolean` | `true` | Enable desktop notifications. |
| `reminderMinutes` | `number` | `10` | Pre-target warning alert in minutes (`0` disables). |
| `catchUpAlert` | `boolean` | `true` | Notify about targets passed during system suspend/sleep. |
| `weekStart` | `string` | `"monday"` | Week start day: `"monday"` or `"sunday"`. |
| `workHours` | `object` | `{"start":"08:00", "end":"20:00"}` | Active window filter for focus statistics. |

---

## 📋 Requirements

All dependencies ship natively with Omarchy:

| Component | Status | Purpose |
| :--- | :--- | :--- |
| `omarchy-notification-send` | Required | Native desktop notifications on target starts and deadlines |
| `jq` | Optional | CLI parsing of local goal state from external scripts |

### Privacy & Architecture
- **Strictly Offline**: Never initiates network connections.
- All schedules, streak counts, and progress calculations are evaluated locally on your CPU.
- State writes are atomic (`fsync` + replace).

---

## 🗑️ Uninstallation

To remove the plugin:

```bash
omarchy plugin remove daily.focus
```

This unloads the plugin, clears it from the bar, and creates a timestamped backup. Your targets and history logs are preserved so reinstallation picks up where you left off.

To wipe all data completely:

```bash
rm -rf ~/.config/omarchy/focus ~/.local/state/omarchy/focus
```

> **Safety**: The plugin touches nowhere else. It does not alter `shell.json` or external user files.

---

## 📂 Project Structure

```plaintext
omarchy-daily-focus/
├── manifest.json          # Plugin manifest (registers background service & bar widget)
├── Service.qml            # Background event loop: timer triggers, notifications, suspend checks
├── BarWidget.qml          # Bar pill showing target countdown and radial progress indicator
├── Panel.qml              # Weekly planner view, goal entry, and configuration view
├── components/            # Reusable QML elements (progress ring, task row, countdown dial)
├── lib/
│   ├── Scheduler.js       # Timeline parsing, countdown timers, and deadline calculation
│   └── Store.js           # JSON state sync, atomic writes, and schema validation
├── test/                  # Isolated unit tests executed via Node.js
│   └── scheduler.test.js
└── docs/                  # Screenshots and ARCHITECTURE.md
```

---

## 🧪 Testing & Development

```bash
# 1. Clone into local plugins directory
git clone https://github.com/yared2124/omarchy-daily-focus.git \
  ~/.config/omarchy/plugins/daily.focus

# 2. Run unit tests
node test/scheduler.test.js

# 3. Validate plugin manifest and assets
omarchy plugin validate .

# 4. Restart shell to load changes
omarchy restart shell
```

---

## 🤝 Contributing

Pull requests, feature suggestions, and bug reports are welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines and coding standards.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
