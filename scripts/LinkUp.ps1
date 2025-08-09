Add-Type -AssemblyName PresentationFramework

# Load UI
[xml]$xaml = Get-Content -Raw -Path "$PSScriptRoot\UI.xaml"
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Bind UI controls to PowerShell variables
$StreakLabel    = $window.FindName("StreakLabel")
$ConfigList     = $window.FindName("ConfigList")
$LaunchButton   = $window.FindName("LaunchButton")
$PomodoroButton = $window.FindName("PomodoroButton")
$ExitButton     = $window.FindName("ExitButton")

# =======================
# Paths & Constants
# =======================
# Get the directory path of the current script
$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Get the parent directory of the script's directory (one level up)
$ParentDir = Split-Path -Parent $BaseDir
$HistoryDir   = Join-Path $ParentDir "history"
$ConfigDir    = Join-Path $ParentDir "configs"
$StreakFile   = Join-Path $HistoryDir "streak.txt"
$HistoryFile  = Join-Path $HistoryDir "history.txt"
$UsageFile    = Join-Path $HistoryDir "usage_count.txt"
$ChromePath   = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# =======================
# Ensure required folders exist
# =======================
if (!(Test-Path $HistoryDir)) { New-Item -ItemType Directory -Path $HistoryDir | Out-Null }
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir | Out-Null }

# Load functions & buttons
. "$PSScriptRoot\Functions.ps1"
. "$PSScriptRoot\Buttons.ps1"

# =======================
# Run UI
# =======================
$window.ShowDialog() | Out-Null
