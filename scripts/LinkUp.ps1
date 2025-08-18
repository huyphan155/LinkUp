Add-Type -AssemblyName PresentationFramework

# Load UI
[xml]$xaml = Get-Content -Raw -Path "$PSScriptRoot\UserUI\UI.xaml"
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Bind UI controls to PowerShell variables
$StreakLabel             = $window.FindName("StreakLabel")
$ConfigList              = $window.FindName("ConfigList")
$LaunchButton            = $window.FindName("LaunchButton")
$PomodoroButton          = $window.FindName("PomodoroButton")
$ScanTabsButton          = $window.FindName("ScanTabsButton")
$OpenCalcButton          = $window.FindName("OpenCalcButton")
$OpenGithubButton        = $window.FindName("OpenGithubButton") 
$OpenNotionButton        = $window.FindName("OpenNotionButton") 
$OpenSTM32CubeIDEButton  = $window.FindName("OpenSTM32CubeIDEButton") 
$OpenFileExplorerButton  = $window.FindName("OpenFileExplorerButton") 
$OpenBeyondCompareButton = $window.FindName("OpenBeyondCompareButton") 
$OpenVSCodeButton        = $window.FindName("OpenVSCodeButton")
$OpenChatGPT             = $window.FindName("OpenChatGPT")
$OpenGemini              = $window.FindName("OpenGemini")
$ExitButton              = $window.FindName("ExitButton")
$StatusLabel             = $window.FindName("StatusLabel")

# =======================
# Paths & Constants
# =======================
# Get the directory path of the current script
$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Get the parent directory of the script's directory (one level up)
$ParentDir          = Split-Path -Parent $BaseDir
$HistoryDir         = Join-Path $ParentDir "history"
$ConfigDir          = Join-Path $ParentDir "configs"
$StreakFile         = Join-Path $HistoryDir "streak.txt"
$HistoryFile        = Join-Path $HistoryDir "history.txt"
$UsageFile          = Join-Path $HistoryDir "usage_count.txt"
$inputFolderPath    = Join-Path $ParentDir "tabs_export"
$outputTextFilePath = Join-Path $ConfigDir "0.Current_work.txt"

# =======================
# User Input Path
# =======================
$ChromePath         = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$GithubUrl          = "https://github.com/huyphan155" 
$NotionUrl          = "https://www.notion.so/huyphann155/arm-cortex-m3m4-238f5b92155e8066a1ddd112e84b9f9f" 
$STM32CubeIDEPath   = "C:\ST\STM32CubeIDE_1.14.1\STM32CubeIDE\stm32cubeide.exe"
$FileExplorerPath   = "D:\GitWork" 
$BeyondComparePath  = "C:\Program Files\Beyond Compare 4\BCompare.exe"
$VSCodePath         = "C:\Users\Admin\AppData\Local\Programs\Microsoft VS Code\Code.exe"
$ChatGPTUrl         = "https://chatgpt.com"
$GeminiUrl          = "https://gemini.google.com/app"

# =======================
# Ensure required folders exist
# =======================
if (!(Test-Path $HistoryDir)) { New-Item -ItemType Directory -Path $HistoryDir | Out-Null }
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir | Out-Null }
if (!(Test-Path $inputFolderPath)) { New-Item -ItemType Directory -Path $inputFolderPath | Out-Null }


# =======================
# Function to update status message
# =======================
function Set-StatusMessage {
    param(
        [string]$Message,
        [int]$DurationSeconds = 3, # Message will disappear after this many seconds
        [string]$MessageType = "Information" # Can be "Information", "Warning", "Error", "Success"
    )

    # Use $script:StatusLabel to access the global variable defined in LinkUp.ps1
    # This is important when calling Set-StatusMessage from other scripts like Buttons.ps1 or Functions.ps1
    if ($script:StatusLabel) {
        $script:StatusLabel.Text = $Message
        switch ($MessageType) {
            "Information" { $script:StatusLabel.Foreground = "#2980B9" } # Blue
            "Warning"     { $script:StatusLabel.Foreground = "#F39C12" } # Orange
            "Error"       { $script:StatusLabel.Foreground = "#C0392B" } # Red
            "Success"     { $script:StatusLabel.Foreground = "#27AE60" } # Green
            default       { $script:StatusLabel.Foreground = "#2980B9" }
        }

        # Clear message after duration
        if ($DurationSeconds -gt 0) {
            # Use Start-Job to run the sleep and clear text in background
            # so UI remains responsive.
            Start-Job -ScriptBlock {
                param($label, $duration)
                Start-Sleep -Seconds $duration
                $label.Dispatcher.Invoke([Action]{ $label.Text = "" })
            } -ArgumentList $script:StatusLabel, $DurationSeconds | Out-Null
        }
    }
}

# Load functions & buttons
. "$PSScriptRoot\Functions.ps1"
. "$PSScriptRoot\Buttons.ps1"

# =======================
# Run UI
# =======================
$window.ShowDialog() | Out-Null
