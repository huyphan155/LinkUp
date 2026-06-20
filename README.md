1. Install UV : powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
Check : uv --version
   2. init : uv init
       => pyproject.toml
          README.md
          .python-version
3. virtual environment : uv venv
4. active : .venv\Scripts\activate
5.  package install 
uv add customtkinter
uv add pydantic


            main.py
            ↓
            WorkspaceService.load()
            ↓
            Workspace object
            ↓
            LauncherService.launch(workspace)
            ↓
            for item in workspace.items
            ↓
            nếu là UrlItem
            ↓
            webbrowser.open()
            ↓
            nếu là ExecutableItem
            ↓
            subprocess.Popen()


                    workspace.json
                           │
                           ▼
                WorkspaceService
                           │
                           ▼
                   Workspace Object
                           │
                           ▼
                  LauncherService
                           │
          ┌────────────────┴────────────────┐
          ▼                                 ▼
      UrlItem                         ExecutableItem
          ▼                                 ▼
  webbrowser.open()              subprocess.Popen()


src/
└── linkup/
    ├── main.py                            : launch service from workspace
    │
    ├── models/
    │   ├── workspace.py                   : show data of a workspace
    │   ├── base_item.py                   : show data of a item
    │   ├── url_item.py                    : show data of a item + URL
    │   └── executable_item.py             : show data of a item + Arguments
    │
    ├── services/
    │   ├── workspace_service.py           : workspace.json -> object -> workspace
    │   └── launcher_service.py            : receive object -> workspace -> open web / open app
    │
    ├── ui/
    │
    └── utils/

# LinkUp

Workspace Automation Tool

## Features

- Workspace
- URL Launcher
- Executable Launcher

## Tech Stack

- Python
- CustomTkinter
- SQLite
- Pydantic

## Installation

```bash
uv sync

```RUN
uv run linkup