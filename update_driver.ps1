Param(
    [Parameter(Mandatory=$true)]
    [string]$UpdateTitle
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "PROGRESS: 10: Inicializace vyhledávání ovladače..."
Write-Output "Hledám aktualizaci ovladače: $UpdateTitle..."

$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()
# Fast local search first
$updateSearcher.Online = $false
$searchResult = $updateSearcher.Search("Type='Driver' and IsInstalled=0")

if ($null -eq $searchResult -or $searchResult.Updates.Count -eq 0) {
    Write-Output "PROGRESS: 15: Hledání na vzdálených serverech Windows Update..."
    Write-Output "Hledám na vzdálených serverech Windows Update..."
    $updateSearcher.Online = $true
    $searchResult = $updateSearcher.Search("Type='Driver' and IsInstalled=0")
}

$targetUpdate = $null

# 1. Exact match (Title or DriverModel)
if ($null -ne $searchResult -and $null -ne $searchResult.Updates) {
    foreach ($update in $searchResult.Updates) {
        if ($update.Title -eq $UpdateTitle -or $update.DriverModel -eq $UpdateTitle) {
            $targetUpdate = $update
            break
        }
    }
}

# 2. Fuzzy / keyword match (e.g. NVIDIA, Intel, Ethernet, Display, Realtek)
if ($null -eq $targetUpdate -and $null -ne $searchResult -and $null -ne $searchResult.Updates) {
    $normTarget = $UpdateTitle.ToLower()
    foreach ($update in $searchResult.Updates) {
        $uTitle = ""
        if ($update.Title) { $uTitle = $update.Title.ToLower() }
        $uModel = ""
        if ($update.DriverModel) { $uModel = $update.DriverModel.ToLower() }
        
        if ($normTarget -like "*nvidia*" -and ($uTitle -like "*nvidia*" -or $uModel -like "*nvidia*")) {
            $targetUpdate = $update
            break
        }
        if ($normTarget -like "*intel*" -and ($uTitle -like "*intel*" -or $uModel -like "*intel*")) {
            $targetUpdate = $update
            break
        }
        if ($normTarget -like "*realtek*" -and ($uTitle -like "*realtek*" -or $uModel -like "*realtek*")) {
            $targetUpdate = $update
            break
        }
    }
}

# 3. If found in Windows Update, download and install with progressive feedback
if ($null -ne $targetUpdate) {
    $dispName = if ($targetUpdate.DriverModel) { $targetUpdate.DriverModel } else { $targetUpdate.Title }
    Write-Output "Nalezena aktualizace ve Windows Update: $($targetUpdate.Title) ($dispName)"
    Write-Output "PROGRESS: 25: Stahování instalačního balíčku..."
    Write-Output "Stahování instalačního balíčku..."

    $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
    $updatesToInstall.Add($targetUpdate) | Out-Null

    $downloader = $updateSession.CreateUpdateDownloader()
    $downloader.Updates = $updatesToInstall
    
    # Download with background thread monitoring for smooth UI progression
    try {
        $dlThread = [powershell]::Create().AddScript({
            param($d)
            return $d.Download()
        }).AddArgument($downloader)
        $asyncDl = $dlThread.BeginInvoke()
        $curDlPct = 25
        while (-not $asyncDl.IsCompleted) {
            Start-Sleep -Milliseconds 600
            if ($curDlPct -lt 74) {
                $curDlPct += 2
                Write-Output "PROGRESS: ${curDlPct}: Stahování instalačního balíčku (${curDlPct}%)..."
            }
        }
        $downloadResult = $dlThread.EndInvoke($asyncDl)[0]
        $dlThread.Dispose()
    } catch {
        $downloadResult = $downloader.Download()
    }

    Write-Output "PROGRESS: 75: Stahování dokončeno (Kód: $($downloadResult.ResultCode)). Příprava instalace..."
    Write-Output "Stahování dokončeno (Kód: $($downloadResult.ResultCode)). Spouštění instalace..."

    if ($downloadResult.ResultCode -ne 2) {
        Write-Output "[Chyba] Stahování ovladače se nezdařilo (Výsledný kód: $($downloadResult.ResultCode))."
        exit 1
    }

    Write-Output "PROGRESS: 80: Spouštění instalace balíčku do systému..."
    $installer = $updateSession.CreateUpdateInstaller()
    $installer.Updates = $updatesToInstall
    
    # Install with background thread monitoring for smooth UI progression
    try {
        $instThread = [powershell]::Create().AddScript({
            param($inst)
            return $inst.Install()
        }).AddArgument($installer)
        $asyncInst = $instThread.BeginInvoke()
        $curInstPct = 80
        while (-not $asyncInst.IsCompleted) {
            Start-Sleep -Milliseconds 500
            if ($curInstPct -lt 95) {
                $curInstPct += 1
                Write-Output "PROGRESS: ${curInstPct}: Probíhá instalace ovladače (${curInstPct}%)..."
            }
        }
        $installResult = $instThread.EndInvoke($asyncInst)[0]
        $instThread.Dispose()
    } catch {
        $installResult = $installer.Install()
    }

    Write-Output "Instalace dokončena (Kód: $($installResult.ResultCode))."
    
    if ($installResult.ResultCode -eq 2 -or $installResult.ResultCode -eq 3) {
        Write-Output "PROGRESS: 100: Instalace ovladače byla úspěšně dokončena."
        if ($installResult.RebootRequired) {
            Write-Output "SYSTEM_REBOOT_REQUIRED"
        }
        exit 0
    } else {
        Write-Output "[Chyba] Instalace ovladače selhala (Kód výsledku: $($installResult.ResultCode))."
        exit 1
    }
}

# 4. If NOT found in Windows Update catalog:
Write-Output "PROGRESS: 100: Aktualizace nedostupná ve Windows Update."
Write-Output "[Upozornění] Ovladač pro '$UpdateTitle' není přímo dostupný v katalogu Windows Update."
Write-Output "[Doporučení] Pro toto zařízení je nutné stáhnout instalační balíček přímo z oficiálních stránek výrobce hardwaru (např. Intel Driver & Support Assistant)."
exit 1
