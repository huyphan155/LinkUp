# 🚀 LinkUp

LinkUp is a simple Windows batch tool that automatically opens Chrome tabs (with chosen profiles) and apps from a config file.
It also keeps a history log of what you opened and when.

## ✨ Features
✅ **Multiple Chrome profiles** (`Default`, `Profile 1`, etc.)  
✅ **Custom config** for different purposes (Study, Work, etc.)  
✅ **Logs session history** with time, profile, name, and URL

## 📂 Folder Structure
```
LinkUp\
│
├── LinkUp.bat            # Main batch script
├── README.md             # Read me
└── configs\              
     ├── study.txt
     ├── work.txt
     └── ...
├── history\
│    ├── history.txt      # Session history log
│    └── usage_count.txt  # Usage count
└── doc\
```
## 🧑‍💻 Author
Created by **huyphan155** - https://github.com/huyphan155

Get rid of opening all these files and apps every time I want to kick off study!

## 📅 Changelog
- **v1.0.0** (2025-08-02)  
  - Initial release with:
    - Multiple Chrome profiles support
    - Custom config for different purposes
    - Session history logging
- **v1.1.0** (2025-08-02)  
  - Updated release with:
    - automate scan user's config files
    - URL usage count in  history\usage_count.txt
- **v1.1.1** (2025-08-04)  
  - Updated version with:
    - SORT descending in usage count in history\usage_count.txt
    - Pomodoro Mode ⏱️ option
