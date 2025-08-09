# 🚀 LinkUp

LinkUp is a simple tool that automatically opens Chrome tabs (with chosen profiles) and apps from a config file.
It also keeps a history log of what you opened and when.

## ✨ Features
✅ **Custom config** for different purposes (Study, Work, etc.)  
✅ **Multiple Chrome profiles** (`Default`, `Profile 1`, etc.)  
✅ **Logs session history** with time, profile, name, and URL  
✅ **Tracks daily streaks**  
✅ **Pomodoro timer integration**  

## 📂 Folder Structure
```
LinkUp\
│
├── LinkUp.vbs            # VBScript launcher to run to main executed (scripts\LinkUp.ps1)
├── README.md             # Read me
└── configs\              
     ├── "config_name".txt
     └── ...
├── history\
│    ├── history.txt      # Session history log
│    └── usage_count.txt  # Usage URL count
│    └── streak.txt       # streak day(s) in a row
├── scripts\
│    ├── LinkUp.ps1       # Main Executed
│    └── Functions.ps1    # Functions
│    └── Buttons.ps1      # Button event handlers
│    └── UserUI\              
│         ├── "UI".txt    # WPF UI Layout
│         └── ...
└── doc\                  # Documentation and notes
```
## 🧑‍💻 Author
Created by **huyphan155** - https://github.com/huyphan155

Get rid of opening all these files and apps every time I want to kick off study!

## Setup

- You need to manually set your Chrome executable path in the `$ChromePath` variable inside `/scripts/Functions.ps1 `

  - By Default:  `$ChromePath  = "C:\Program Files\Google\Chrome\Application\chrome.exe"`

- You also can change the UI in `/scripts/LinkUp.ps1 `
By Default is using  `UI.xaml""`

## Setup

**You need to manually set your Chrome executable path in the `$ChromePath` variable inside `/scripts/Functions.ps1`**  
   - By Default :  
     ```powershell
     $ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
     ```

**You can customize the UI by editing the `/script/LinkUp.ps1`**  
   - By default, it loads the UI from: `UI.xaml`


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
    - Update 🔥 Streak feature
    - Countdown before launch
- **v2.0.0** (2025-08-09)
  - Updated release with:
    - Migrated from BAT script to PowerShell (.ps1) for improved flexibility and maintainability.
    - Added modern WPF GUI (Windows Presentation Foundation)
    - Re-Organize folder structure
    - Customize UI
