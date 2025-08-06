Add-Type -AssemblyName PresentationFramework

# =======================
# XAML UI Layout
# =======================
# Store the XAML layout as a plain string (do not cast to [xml])
# Defines a WPF window with:
# - Title: "LinkUp Adventure"
# - Streak display
# - Config list
# - Buttons: Launch, Pomodoro, Exit
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="LinkUp Adventure" Height="420" Width="600"
        Background="#FFFDFDFD" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="15">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Text="🗡️  LinkUp Adventure" FontSize="24" FontWeight="Bold"
                   Foreground="#333" HorizontalAlignment="Center" Margin="0,0,0,10"/>
        <TextBlock x:Name="StreakLabel" Grid.Row="1" FontSize="16" Foreground="#FF5722"
                   HorizontalAlignment="Center" Margin="0,0,0,20"/>
        <ListBox x:Name="ConfigList" Grid.Row="2" FontSize="14" BorderBrush="#CCC"
                 BorderThickness="1"/>
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,20,0,0">
            <Button x:Name="LaunchButton" Content="🚀 Launch" Width="100" Margin="5"
                    Background="#4CAF50" Foreground="White"/>
            <Button x:Name="PomodoroButton" Content="⏱ Pomodoro" Width="100" Margin="5"
                    Background="#2196F3" Foreground="White"/>
            <Button x:Name="ExitButton" Content="❌ Exit" Width="100" Margin="5"
                    Background="#F44336" Foreground="White"/>
        </StackPanel>
    </Grid>
</Window>
"@

# Load the XAML into a WPF Window object
$reader = (New-Object System.Xml.XmlNodeReader ([xml]$xaml))
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
$BaseDir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$HistoryDir   = Join-Path $BaseDir "history"
$ConfigDir    = Join-Path $BaseDir "configs"
$StreakFile   = Join-Path $HistoryDir "streak.txt"
$HistoryFile  = Join-Path $HistoryDir "history.txt"
$UsageFile    = Join-Path $HistoryDir "usage_count.txt"
$ChromePath   = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# =======================
# Ensure required folders exist
# =======================
if (!(Test-Path $HistoryDir)) { New-Item -ItemType Directory -Path $HistoryDir | Out-Null }
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir | Out-Null }

# =======================
# Daily Streak Tracking
# =======================
# The streak.txt file stores:
#   yyyy-MM-dd|<streak_days>
# Each day the script checks the last recorded date and updates the streak count.
$Today = Get-Date -Format "yyyy-MM-dd"

if (!(Test-Path $StreakFile)) {
    "$Today|1" | Out-File $StreakFile -Encoding utf8
} else {
    $parts = Get-Content $StreakFile -Raw | ForEach-Object { $_ -split '\|' }
    $LastDate = $parts[0]
    $Streak = [int]$parts[1]

    $diff = (New-TimeSpan -Start (Get-Date $LastDate) -End (Get-Date $Today)).Days
    if ($diff -eq 1) {
        $Streak++
    } elseif ($diff -gt 1) {
        $Streak = 1
    }
    "$Today|$Streak" | Out-File $StreakFile -Encoding utf8
}

# Display current streak in the UI
$parts = Get-Content $StreakFile -Raw | ForEach-Object { $_ -split '\|' }
$StreakLabel.Text = "🔥 Streak: $($parts[1]) day(s) in a row"

# =======================
# Load Config Files
# =======================
# Config files (.txt) are stored in the configs/ folder
$ConfigList.Items.Clear()
Get-ChildItem "$ConfigDir\*.txt" | ForEach-Object {
    $ConfigList.Items.Add($_.Name) | Out-Null
}

# =======================
# Function: Update usage count
# =======================
# Keeps track of how many times each URL is opened.
# Stored in: usage_count.txt
function Update-UsageCount {
    param([string]$url)

    if (!(Test-Path $UsageFile)) { New-Item -ItemType File -Path $UsageFile | Out-Null }

    $found = $false
    $temp = @()

    foreach ($line in Get-Content $UsageFile) {
        if ($line -match '^\s*$') { continue }
        $parts = $line -split '\|'
        if ($parts[0] -eq $url) {
            $count = [int]$parts[1] + 1
            $temp += "$url|$count"
            $found = $true
        } else {
            $temp += $line
        }
    }

    if (-not $found) {
        $temp += "$url|1"
    }

    $sorted = $temp | Where-Object { $_ -match '\|' } |
        Sort-Object { [int]($_ -split '\|')[1] } -Descending

    $sorted | Out-File $UsageFile -Encoding utf8
}

# =======================
# Button: Launch selected config
# =======================
# Reads the selected config file and:
#   - Opens each URL in Chrome (with specified profile)
#   - Updates usage count
#   - Logs history to history.txt
$LaunchButton.Add_Click({
    $selected = $ConfigList.SelectedItem
    if (-not $selected) { [System.Windows.MessageBox]::Show("Please select a config first.") ; return }

    $configPath = Join-Path $ConfigDir $selected

    # Log session start
    $timestamp = Get-Date -Format "ddd MM/dd/yyyy HH:mm:ss.ff"
    Add-Content $HistoryFile "==== $timestamp - Open from configs\$selected ===="

    foreach ($line in Get-Content $configPath) {
        if ($line.Trim() -eq "" -or $line.Trim().StartsWith("#")) { continue }
        $parts = $line -split '\|'
        $profile = $parts[0].Trim()
        $url = $parts[1].Trim()
        $name = ""
        if ($parts.Count -ge 3) { $name = $parts[2].Trim() }

        # Open Chrome with profile
        Start-Process $ChromePath "--profile-directory=`"$profile`" $url"

        # Update usage count
        Update-UsageCount $url

        # Log to history
        if ($name -eq "") {
            Add-Content $HistoryFile "[${profile}] $url"
        } else {
            Add-Content $HistoryFile "[${profile}] $name - $url"
        }
    }

    Add-Content $HistoryFile ""
    [System.Windows.MessageBox]::Show("All tabs & apps launched successfully!")
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
# Button: Exit
# =======================
# Closes the application window
$ExitButton.Add_Click({
    $window.Close()
})

# =======================
# Run UI
# =======================
$window.ShowDialog() | Out-Null
