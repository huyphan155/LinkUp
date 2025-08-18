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
            $found = true
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
# Function: Convert Tab CSVs to a single Text File
# =======================
# Scans all CSV files in a specified folder, extracts URL, Title, and Profile Name,
# then formats and combines them into a single text file.
function Convert-TabCsvsToText {
    param(
        [string]$InputFolderPath,
        [string]$OutputTextFilePath
    )

    # Array to store all formatted lines from all CSV files
    $formattedLines = @()

    Set-StatusMessage "Starting CSV file scan in folder: $InputFolderPath" -1 "Information"

    # Get all CSV files in the specified folder
    try {
        $csvFiles = Get-ChildItem -Path $InputFolderPath -Filter "*.csv" -File
    }
    catch {
        Set-StatusMessage "Cannot access folder: $($_.Exception.Message). Please check the folder path and permissions." 5 "Error"
        return
    }

    if ($csvFiles.Count -eq 0) {
        Set-StatusMessage "No CSV files found in folder: $InputFolderPath" 3 "Warning"
        return
    }

    # Loop through each found CSV file
    foreach ($csvFile in $csvFiles) {
        Set-StatusMessage "Processing file: $($csvFile.Name)" -1 "Information" # Message stays until next one
        try {
            # Read the content of the CSV file
            # Ensure "Domain", "URL", "Title", and "Profile Name" columns are read correctly
            $tabs = Import-Csv -Path $csvFile.FullName
            
            # Loop through each row (tab) in the current CSV file and format it
            foreach ($tab in $tabs) {
                # Check if properties exist to avoid errors with non-standard CSVs
                # Use .psobject.Properties.Name to safely check column existence
                $domain = if ($tab.psobject.Properties.Name -contains "Domain") { $tab.Domain } else { "" }
                $url = if ($tab.psobject.Properties.Name -contains "URL") { $tab.URL } else { "" }
                $title = if ($tab.psobject.Properties.Name -contains "Title") { $tab.Title } else { "" }
                # Read "Profile Name" column, default to "Default" if not found
                $profileName = if ($tab.psobject.Properties.Name -contains "Profile Name") { $tab."Profile Name" } else { "Default" }

                # Use the full original URL directly, no extraction needed
                $fullOriginalUrl = $url

                # Remove double quotes from Title and Profile Name (if present)
                $cleanTitle = $title -replace '"', ''
                $cleanProfileName = $profileName -replace '"', ''

                # Format the line as required: "web | Profile Name | Full Original URL | Title"
                $formattedLine = "web | $($cleanProfileName) | $($fullOriginalUrl) | $($cleanTitle)"
                $formattedLines += $formattedLine
            }
        }
        catch {
            Set-StatusMessage "Error processing file $($csvFile.Name): $($_.Exception.Message)" 5 "Error"
        }
    }

    # Write all formatted lines to the single output text file
    # Changed encoding to Unicode for potentially better Vietnamese character display
    try {
        $formattedLines | Out-File -FilePath $OutputTextFilePath -Encoding Unicode
        Set-StatusMessage "Conversion complete! All data saved to: $OutputTextFilePath" 5 "Success"
    }
    catch {
        Set-StatusMessage "Cannot write to output text file: $($_.Exception.Message). Check file path and permissions." 5 "Error"
    }
}
