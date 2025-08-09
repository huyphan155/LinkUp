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
        Title="LinkUp Adventure" Height="450" Width="650"
        Background="#FAFAFA" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Window.Resources>

        <!-- Style: Modern Rounded Button -->
        <Style TargetType="Button">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="8,4"/>
            <Setter Property="Margin" Value="6"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border"
                                Background="{TemplateBinding Background}"
                                CornerRadius="8"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center"
                                              VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#3498DB"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1F618D"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Background" Value="#BDC3C7"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Title -->
        <TextBlock Text="🗡️ LinkUp Adventure"
                   FontSize="28" FontWeight="Bold"
                   Foreground="#2C3E50"
                   HorizontalAlignment="Center"
                   Margin="0,0,0,15">
            <TextBlock.Effect>
                <DropShadowEffect Color="#888" BlurRadius="5" ShadowDepth="2"/>
            </TextBlock.Effect>
        </TextBlock>

        <!-- Streak -->
        <TextBlock x:Name="StreakLabel" Grid.Row="1"
                   FontSize="18" Foreground="#E67E22"
                   HorizontalAlignment="Center" Margin="0,0,0,20"/>

        <!-- Config List -->
        <ListBox x:Name="ConfigList" Grid.Row="2" FontSize="14"
                 BorderBrush="#BDC3C7" BorderThickness="1"
                 Background="White" Padding="5" />

        <!-- Buttons -->
        <StackPanel Grid.Row="3" Orientation="Horizontal"
                    HorizontalAlignment="Center" Margin="0,25,0,0">
            <Button x:Name="LaunchButton" Content="🚀 Launch"
                    Background="#27AE60"/>
            <Button x:Name="PomodoroButton" Content="⏱ Pomodoro"
                    Background="#2980B9"/>
            <Button x:Name="ExitButton" Content="❌ Exit"
                    Background="#C0392B"/>
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
    if (-not $selected) {
        [System.Windows.MessageBox]::Show("Please select a config first.") 
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
                    [System.Windows.MessageBox]::Show("App not found: $profile")
                }
            }
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
