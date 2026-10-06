# Contributing to Omarchy Daily Focus 🎯

Thank you for your interest in contributing to **Omarchy Daily Focus** (`daily.focus`)! We welcome bug reports, feature suggestions, UI polish, and pull requests to help make daily goal tracking inside Omarchy fast, reliable, and delightful.

---

## 📜 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Development Setup](#development-setup)
- [Running Tests](#running-tests)
- [Coding Standards](#coding-standards)
  - [QML Guidelines](#qml-guidelines)
  - [JavaScript (`lib/`) Guidelines](#javascript-lib-guidelines)
  - [Privacy & Architecture Invariants](#privacy--architecture-invariants)
- [Git Commit Guidelines](#git-commit-guidelines)
- [Submitting a Pull Request](#submitting-a-pull-request)

---

## Code of Conduct

We are committed to providing a welcoming, inclusive, and harassment-free experience for everyone. Please be respectful, constructive, and kind in all issues, discussions, and code reviews.

---

## Development Setup

### Prerequisites
- **Node.js** (v18 or newer)
- **Docker** and **Docker Compose** (optional, for running containerized test suites)
- **Omarchy Shell** with Hyprland (for live desktop integration testing)

### Local Setup
Clone this repository directly into your local Omarchy plugins directory:

```bash
# Clone into plugins path
git clone https://github.com/yared2124/omarchy-daily-focus.git ~/.config/omarchy/plugins/daily.focus
cd ~/.config/omarchy/plugins/daily.focus
```

To live test changes inside Omarchy:
```bash
# Restart the shell to reload QML bytecode
omarchy restart shell
```

---

## Running Tests

All core scheduling, progress calculation, and JSON storage logic have automated unit tests that can be run either locally with Node.js or inside Docker.

### Local Node.js Test Runner
```bash
node test/scheduler.test.js
```

### Docker Test Suite
```bash
docker compose run --rm test
```

All test assertions must pass before submitting your pull request.

---

## Coding Standards

### QML Guidelines
- **Target Qt Quick 2.15**: Maintain compatibility with Omarchy's Qt 5 / Qt 6 runtime bridge.
- **Theme Consistency**: Use the NestJS design palette (dark obsidian surfaces with signature crimson ruby red accents):
  - Background: `#12131a` / Card Background: `#181a24` / Hover Surface: `#222436`
  - Text: Primary `#ffffff`, Muted `#94a3b8`, Subtext `#64748b`
  - Brand Primary / Accent: `#e0234e` (NestJS Red), Hover: `#f43f5e`
  - Success / Done: `#10b981` (Emerald Green)
  - Warning / Normal Priority: `#f59e0b` (Amber Orange)
  - Info / Low Priority: `#38bdf8` (Cyan Blue)
  - Alert / Overdue: `#e0234e` (NestJS Red)
  - Borders: `#2a2d3f` / Hover: `#3d4059` / Focus: `#e0234e`
- **Declarative Layouts**: Prefer `RowLayout` and `ColumnLayout` over hard-coded absolute x/y coordinates.
- **Component Modularity**: Reusable UI widgets (rings, list rows, badge buttons) should live in `components/`.

### JavaScript (`lib/`) Guidelines
- Keep business logic decoupled from Qt-specific APIs whenever possible so that unit tests can execute cleanly under standard Node.js environments.
- Use explicit error handling and safe fallbacks when parsing or manipulating dates and JSON.
- Disk operations must always be atomic (write to `.tmp` file and rename/replace) to prevent partial file writes during sudden system shutdowns.

### Privacy & Architecture Invariants
- **100% Offline**: Do not introduce any network requests, telemetry, external analytics, or remote API queries.
- **Isolated Storage**: Only write to authorized user directories:
  - Configuration: `~/.config/omarchy/focus/`
  - Runtime State: `~/.local/state/omarchy/focus/`
- Avoid touching external user files or global shell configurations outside of the plugin scope.

---

## Git Commit Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) to keep the commit history clean and understandable:

- `feat(ui)`: New user-facing feature or component (e.g. `feat(ui): add weekly timeline view`)
- `fix(scheduler)`: Bug fix (e.g. `fix(scheduler): fix countdown formatting when seconds is disabled`)
- `docs`: Documentation updates or additions (e.g. `docs: add ARCHITECTURE.md`)
- `test`: Adding or modifying tests (e.g. `test: add suspend resume catch-up unit tests`)
- `refactor`: Code improvements that do not change functionality
- `chore`: Maintenance tasks, CI changes, dependency updates

---

## Submitting a Pull Request

1. **Fork** the repository and create a new feature branch:
   ```bash
   git checkout -b feat/my-new-feature
   ```
2. **Make your changes**, keeping them focused and well-scoped.
3. **Run the test suite** and ensure all tests pass:
   ```bash
   node test/scheduler.test.js
   ```
4. **Commit** your changes using conventional commit messages:
   ```bash
   git commit -m "feat(ui): add milestone filter to panel"
   ```
5. **Push** to your fork and submit a **Pull Request** to the `main` branch.
6. Provide a clear description in your PR outlining what was changed, screenshots if UI elements were modified, and how it was tested.

Thank you for helping make Omarchy Daily Focus even better! 🚀
