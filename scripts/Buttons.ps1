# =======================
# Button: Launch selected config
# =======================
# Reads the selected config file and:
#   - Opens each URL in Chrome (with specified profile)
#   - Updates usage count
#   - Logs history to history.txt
$LaunchButton.Add_Click({
    $selected = $ConfigList.SelectedItem
    if (-not $selected) {
        Set-StatusMessage "Please select a config first." 3 "Warning"
        return
    }

    $configPath = Join-Path $ConfigDir $selected

    # Log session start
    $timestamp = Get-Date -Format "ddd MM/dd/yyyy HH:mm:ss.ff"
    Add-Content $HistoryFile "==== $timestamp - Open from configs\$selected ===="

    foreach ($line in Get-Content $configPath) {
        if ($line.Trim() -eq "" -or $line.Trim().StartsWith("#")) { continue }

        # Split & Trim all parts
        $parts = $line -split '\|' | ForEach-Object { $_.Trim() }

        $type    = $parts[0].ToLower()
        $profile = $parts[1]
        $target  = $parts[2]
        $name    = if ($parts.Count -ge 4) { $parts[3] } else { "" }

        switch ($type) {
            "web" {
                Start-Process $ChromePath "--profile-directory=`"$profile`" $target"
                Update-UsageCount $target
                Add-Content $HistoryFile "[web] $name - $target"
            }
            "app" {
                if (Test-Path $profile) {
                    Start-Process $profile
                    Add-Content $HistoryFile "[app] $target"
                }
                else {
                    Set-StatusMessage "App not found: $profile" 5 "Error"
                }
            }
        }
    }

    Add-Content $HistoryFile ""
    Set-StatusMessage "All tabs & apps launched successfully!" 3 "Success"
})



# =======================
# Button: Pomodoro
# =======================
# Opens Pomofocus in Chrome (Default profile) and auto-starts timer after 5s
$PomodoroButton.Add_Click({
    # Launch Pomofocus
    Set-StatusMessage "Opening Pomodoro app..." 2 "Information"
    Start-Process $ChromePath "--profile-directory=`"Default`" https://pomofocus.io"

    # Wait for page to load, then simulate pressing Space to start timer
    Start-Sleep -Seconds 5
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait(" ")
    Set-StatusMessage "Pomodoro timer started!" 3 "Success"
})

# =======================
# Button: Scan Tabs
# =======================
# Scans CSV files from a designated folder and converts them to a single text file
$ScanTabsButton.Add_Click({
    Set-StatusMessage "Scanning tabs in folder '$InputFolderPath'..." -1 "Information" # -1 means message won't disappear automatically
    # Convert-TabCsvsToText now handles its own status messages inside the function
    Convert-TabCsvsToText -InputFolderPath $InputFolderPath -OutputTextFilePath $outputTextFilePath
})

# =======================
# Button: Open Calculator
# =======================
# Opens Calculator
$OpenCalcButton.Add_Click({ # Using OpenCalcButton as per your UI.xaml and LinkUp.ps1
    try {
        Set-StatusMessage "Opening Calculator..." 2 "Information"
        Start-Process "calc.exe"
        Set-StatusMessage "Calculator opened!" 3 "Success"
    }
    catch {
        Set-StatusMessage "Cannot Open Calculator: $($_.Exception.Message)" 5 "Error"
    }
})

# =======================
# Button: Open ChatGPT
# =======================
# Opens ChatGPT in Chrome
$OpenChatGPT.Add_Click({
    try {
        Set-StatusMessage "Opening ChatGPT..." 2 "Information"
        Start-Process $ChromePath "--profile-directory=`"Default`" $ChatGPTUrl"
        Set-StatusMessage "ChatGPT opened!" 3 "Success"
    }
    catch {
        Set-StatusMessage "Cannot Open ChatGPT: $($_.Exception.Message)" 5 "Error"
    }
})

# =======================
# Button: Exit
# =======================
# Closes the application window
$ExitButton.Add_Click({
    $window.Close()
})
