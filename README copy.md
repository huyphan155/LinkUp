# 🚀 LinkUp
Phase 1 : Design
  ✓ B1. Requirement
  ✓ B2. Architecture
  ✓ B3. Data Model
  ✓ B4. Folder Structure
Phase 2 : Core
Phase 3 : UI
Phase 4 : Database
Phase 5 : Feature
Phase 6 : Packaging
Phase 7 : Polish



UI
│
├──────────────┐
│              │
▼              ▼

Services     Core

│              │

└───────► Models

        │

      Database

UI : call to launcher.launch("Study")
Core : the "brain" 
Services : serivec jobs
Models : data define 


LinkUp/
│
├── app.py                 # Entry point
├── requirements.txt
├── README.md
│
├── config/
│   └── config.json
│
├── data/
│   └── history.db
│
├── app/
│   ├── core/
│   │   ├── launcher.py
│   │   ├── browser.py
│   │   └── application.py
│   │
│   ├── models/
│   │   ├── profile.py
│   │   ├── item.py
│   │   └── history.py
│   │
│   ├── services/
│   │   ├── config_service.py
│   │   ├── history_service.py
│   │   └── search_service.py
│   │
│   ├── ui/
│   │   ├── main_window.py
│   │   ├── sidebar.py
│   │   ├── profile_view.py
│   │   └── widgets/
│   │
│   └── utils/
│       ├── logger.py
│       └── file_helper.py
│
└── tests/


Workspace
│
├── Metadata
│
├── Items
│     │
│     ├── BrowserItem
│     ├── AppItem
│     ├── FolderItem
│     ├── ScriptItem
│     ├── CommandItem
│     └── ...
│
└── Settings

P1 : Design

Requirement
↓
High Level Design
↓
Code MVP
↓
Review
↓
Refactor
↓
Feature
↓
Repeat

P2 : Use Case

Use Case 1 - Create Workspace
User
↓
Click New Workspace
↓
Capture Current Workspace
↓
User chọn những Item muốn lưu
↓
Đặt tên
↓
Save

Use Case 2 - Launch Workspace
User
↓
Click Workspace
↓
Launch
↓
Load JSON
↓
Validate
↓
Sort Dependencies
↓
Launch Item #1
↓
Launch Item #2
↓
...
↓
Save History
↓
Done

Use Case 3 - Edit Workspace
Workspace
↓
Add Item
↓
Remove Item
↓
Disable Item
↓
Rename
↓
Save

Use Case 4 - Search
User
↓
Search "git"
↓
Workspace Engine
↓
Filter
↓
Update UI


LinkUp/
│
├── app.py
├── README.md
├── requirements.txt
├── .gitignore
│
├── config/
│   └── workspace.json
│
├── app/
│   ├── __init__.py
│   │
│   ├── core/
│   │     └── __init__.py
│   │
│   ├── models/
│   │     └── __init__.py
│   │
│   ├── services/
│   │     └── __init__.py
│   │
│   ├── launchers/
│   │     └── __init__.py
│   │
│   └── utils/
│         └── __init__.py
│
└── tests/