# 🚀 LinkUp

> Restore your entire Windows workspace with one click.

Capture your Chrome tabs and running desktop applications, then relaunch everything instantly whenever you need.

**One click → Full working environment restored.**

---

## ✨Features

### ✅ Workspace Launcher

Launch multiple workspace profiles simultaneously.

Supported items:

- Chrome URLs
- Windows desktop applications (.exe)

---

### ✅ Chrome Workspace Export

A Chrome Extension exports all opened tabs into a LinkUp workspace file.

Example:

```text
Default.json
Profile1.json
Work.json
```

Each browser profile is exported independently.

---

### ✅ Application Capture (Capture all currently opened desktop applications)

Automatically exports to:

```text
config/current_app.json
```

Supported Most Win32 desktop applications

Ignored:

- Chrome (captured by Extension)
- System processes
- Hidden background windows

---

### ✅ Workspace Preview 
### ✅ Multiple Profile Launch


## 📂 Project Structure

```
LinkUp/
│
├── config/
│   ├── Default.json
│   ├── current_app.json
│   └── ...
│
├── extension/
│   └── Chrome Extension
│
├── src/
│   └── linkup/
│       ├── launchers/
│       ├── models/
│       ├── services/
│       ├── ui/
│       ├── utils/
│       └── main.py
│
└── README.md
```

---

## Workspace Format

```json
{
    "name": "Default",
    "description": "",
    "items": [
        {
            "type": "url",
            "name": "ChatGPT",
            "enabled": true,
            "url": "https://chatgpt.com",
            "profile": "Default"
        },
        {
            "type": "executable",
            "name": "Visual Studio Code",
            "enabled": true,
            "path": "C:\\Program Files\\Microsoft VS Code\\Code.exe",
            "arguments": []
        }
    ]
}
```

---

## Technologies

- Python 3.13
- PyQt6
- pathlib
- dataclasses
- psutil
- pywin32
- Chrome Extension (Manifest V3)

---

## Current Architecture

```
                MainWindow
                     │
     ┌───────────────┼───────────────┐
     │               │               │
     ▼               ▼               ▼
ProfileList     WorkspacePreview   StatusBar
     │
     ▼
ConfigProfileService
     │
     ▼
WorkspaceService
     │
     ▼
Workspace Object
     │
     ▼
LauncherService
```

Business logic is separated from the UI.

- UI only coordinates user actions.
- Services contain business logic.
- Models represent workspace data.

---

## How to Run

Clone repository

```bash
git clone https://github.com/huyphan155/LinkUp.git
```

Install dependencies

```bash
uv sync
```

Run

```bash
uv run src/linkup/main.py
```

---

## Roadmap

### Completed

## 📅 Changelog
- **v1.0.0** (2025-08-02)
- **v1.1.0** (2025-08-02)
- **v1.1.1** (2025-08-04)
- **v2.0.0** (2025-08-09)
- **v2.0.1** (2025-08-10)
- **v2.1.0** (2025-08-16)
- **v2.1.1** (2025-08-18) : Stable Release - V2.1.1 (PowerShell)


- **v3.0.0** (2026-07-21) : Code drop1 - First Public Preview (Rewrie with Python + PyQT6)
  - Initial release with:
      - Workspace Model
      - Workspace Loader
      - Launcher Service
      - Chrome Workspace Export
      - Application Capture
      - Workspace Preview
      - Multi Profile Launch
      - Status Bar
      - PyQt6 Desktop UI


### Planned
- Rename/Delete workspace profiles
- Pomodoro timer integration
- workspace operation
- log
- Settings
- Build executable (.exe)
- Installer
- Auto startup
- Embedded Favorite application 
---
