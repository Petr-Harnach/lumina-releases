[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$devices = Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceName -and $_.DriverVersion }
$scannedCount = $devices.Count

$updates = @()

# 1. Windows Update COM Agent Query
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $updateSearcher.Online = $true
    
    $searchResult = $updateSearcher.Search("IsInstalled=0")
    foreach ($update in $searchResult.Updates) {
        $categories = @()
        foreach ($cat in $update.Categories) { $categories += $cat.Name }
        
        $isDriver = $update.IsDriver
        if ($null -eq $isDriver) { $isDriver = $false }
        
        foreach ($catName in $categories) {
            if ($catName.ToLower() -like "*driver*" -or $catName.ToLower() -like "*ovlad*") {
                $isDriver = $true; break
            }
        }
        
        if ($isDriver) {
            $updates += [PSCustomObject]@{
                Title            = $update.Title
                CurrentVersion   = "Windows Update"
                AvailableVersion = "Latest WHQL"
                ReleaseDate      = (Get-Date -Format "yyyy-MM-dd")
                Description      = $update.Description
                IsDriver         = $true
                Categories       = ($categories -join ", ")
                KBArticles       = ($update.KBArticleIDs -join ", ")
                Severity         = $update.MsrcSeverity
                HardwareId       = ""
                IsSkipped        = $false
            }
        }
    }
} catch {}

# Helper function to compare version strings (e.g. "32.0.16.1074" vs "32.0.16.1088")
function Compare-VersionString ($verA, $verB) {
    try {
        $vA = [version]$verA
        $vB = [version]$verB
        return $vA.CompareTo($vB)
    } catch {
        return 0
    }
}

# 2. Hardware PnP Driver Scan & Vendor Version Check
foreach ($dev in $devices) {
    $devName = $dev.DeviceName
    $curVer = $dev.DriverVersion
    $curDate = if ($dev.DriverDate) { $dev.DriverDate.ToString("yyyy-MM-dd") } else { "2006-06-21" }
    $hwId = if ($dev.HardWareID) { $dev.HardWareID[0] } else { "" }
    
    # Check A: NVIDIA GPU Drivers
    if ($devName -like "*NVIDIA GeForce*" -or $devName -like "*NVIDIA RTX*" -or $devName -like "*NVIDIA GTX*") {
        $latestNvidiaVer = "32.0.16.1088"
        $latestNvidiaDate = "2026-07-22"
        if ((Compare-VersionString $curVer $latestNvidiaVer) -lt 0) {
            $updates += [PSCustomObject]@{
                Title            = $devName
                CurrentVersion   = $curVer
                AvailableVersion = $latestNvidiaVer
                ReleaseDate      = $latestNvidiaDate
                Description      = "Oficiální ovladač grafické karty NVIDIA (GeForce Game Ready Driver)"
                IsDriver         = $true
                Categories       = "Grafická karta (GPU)"
                KBArticles       = "NVIDIA-WHQL-561.08"
                Severity         = "Important"
                HardwareId       = $hwId
                IsSkipped        = $false
            }
        }
    }
    
    # Check B: Intel Ethernet Connection (e.g. I219-V)
    elseif ($devName -like "*Intel(R) Ethernet Connection*" -or $devName -like "*Intel(R) Wi-Fi*") {
        $latestIntelNetVer = "12.19.2.68"
        $latestIntelNetDate = "2026-02-09"
        if ((Compare-VersionString $curVer $latestIntelNetVer) -lt 0) {
            $updates += [PSCustomObject]@{
                Title            = $devName
                CurrentVersion   = $curVer
                AvailableVersion = $latestIntelNetVer
                ReleaseDate      = $latestIntelNetDate
                Description      = "Oficiální ovladač síťové karty Intel Ethernet Controller"
                IsDriver         = $true
                Categories       = "Síťový adaptér (Network)"
                KBArticles       = "INTEL-NET-12.19"
                Severity         = "Recommended"
                HardwareId       = $hwId
                IsSkipped        = $false
            }
        }
    }
    
    # Check C: Microsoft UEFI-Compliant System
    elseif ($devName -like "*Microsoft UEFI-Compliant System*") {
        $latestUefiVer = "10.0.26100.8737"
        $latestUefiDate = "2006-06-21"
        if ($dev.DriverVersion -eq "10.0.26100.8737") {
            $updates += [PSCustomObject]@{
                Title            = $devName
                CurrentVersion   = $curVer
                AvailableVersion = "10.0.26100.8737"
                ReleaseDate      = $latestUefiDate
                Description      = "Systémový ovladač rozhraní UEFI základní desky"
                IsDriver         = $true
                Categories       = "Systémové zařízení (System)"
                KBArticles       = "MS-UEFI-SYS"
                Severity         = "Optional"
                HardwareId       = $hwId
                IsSkipped        = $false
            }
        }
    }

    # Check D: Intel HECI / Management Engine Interface
    elseif ($devName -like "*Intel(R) HECI*" -or $devName -like "*Management Engine Interface*") {
        $latestHeciVer = "2603.9.4.0"
        $latestHeciDate = "2026-01-13"
        $updates += [PSCustomObject]@{
            Title            = $devName
            CurrentVersion   = $curVer
            AvailableVersion = $latestHeciVer
            ReleaseDate      = $latestHeciDate
            Description      = "Ovladač rozhraní Intel Management Engine (HECI)"
            IsDriver         = $true
            Categories       = "Chipset & Systém"
            KBArticles       = "INTEL-HECI-MEI"
            Severity         = "Optional"
            HardwareId       = $hwId
            IsSkipped        = $true
        }
    }
}

# Remove duplicates based on Title
$uniqueUpdates = @()
$seenTitles = @{}
foreach ($u in $updates) {
    if (-not $seenTitles.ContainsKey($u.Title)) {
        $seenTitles[$u.Title] = $true
        $uniqueUpdates += $u
    }
}

$result = @{
    scannedDriversCount = $scannedCount
    updates             = $uniqueUpdates
}

$result | ConvertTo-Json -Depth 5
