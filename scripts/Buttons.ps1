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
        [System.Windows.MessageBox]::Show("Please select a config first.", "LinkUp - Lỗi", "OK", "Warning") 
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
                    [System.Windows.MessageBox]::Show("App not found: $profile", "LinkUp - Lỗi", "OK", "Error")
                }
            }
        }
    }

    Add-Content $HistoryFile ""
})



# =======================
# Button: Pomodoro
# =======================
# Opens Pomofocus in Chrome (Default profile) and auto-starts timer after 5s
$PomodoroButton.Add_Click({
    # Launch Pomofocus
    Start-Process $ChromePath "--profile-directory=`"Default`" https://pomofocus.io"

    # Wait for page to load, then simulate pressing Space to start timer
    Start-Sleep -Seconds 5
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait(" ")
})

# =======================
# Button: Scan Tabs
# =======================
# Scans CSV files from a designated folder and converts them to a single text file
$ScanTabsButton.Add_Click({
    Convert-TabCsvsToText -InputFolderPath $InputFolderPath -OutputTextFilePath $outputTextFilePath
})

# =======================
# Button: Open Calculator
# =======================
# Opens Calculator
$OpenCalcButton.Add_Click({
    try {
        Start-Process "calc.exed"
    }
    catch {
        [System.Windows.MessageBox]::Show("Cannot Open Calculator: $($_.Exception.Message)", "LinkUp - Error", "OK", "Error")
    }
})

# =======================
# Button: Exit
# =======================
# Closes the application window
$ExitButton.Add_Click({
    $window.Close()
})
