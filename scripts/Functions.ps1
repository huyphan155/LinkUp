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
$StreakLabel.Text = "🔥 Streak: $($parts[1])"

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

