[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$devices = Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceName -and $_.DriverVersion }
$scannedCount = $devices.Count

$updates = @()

# Windows Update COM Agent Query for Drivers
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    # Fast local query first to avoid remote cloud timeouts
    $updateSearcher.Online = $false
    $searchResult = $updateSearcher.Search("Type='Driver' and IsInstalled=0")
    
    if ($null -eq $searchResult -or $searchResult.Updates.Count -eq 0) {
        $updateSearcher.Online = $true
        $searchResult = $updateSearcher.Search("Type='Driver' and IsInstalled=0")
    }

    if ($null -ne $searchResult -and $null -ne $searchResult.Updates) {
        foreach ($update in $searchResult.Updates) {
            $categories = @()
            foreach ($cat in $update.Categories) { $categories += $cat.Name }
            
            $isDriver = $update.IsDriver
            if ($null -eq $isDriver) { $isDriver = $false }
            
            foreach ($catName in $categories) {
                if ($catName.ToLower() -like "*driver*" -or $catName.ToLower() -like "*ovlad*") {
                    $isDriver = $true
                    break
                }
            }
            
            if ($isDriver) {
                # Attempt to match with local PnP signed driver to get clean device name and installed version
                $devModel = $update.DriverModel
                $matchedDev = $null
                if ($devModel) {
                    $matchedDev = $devices | Where-Object { $_.DeviceName -eq $devModel } | Select-Object -First 1
                }
                if ($null -eq $matchedDev -and $update.Title) {
                    $prefix = ($update.Title -split '\(')[0].Trim()
                    foreach ($d in $devices) {
                        if ($d.DeviceName -and ($update.Title -like "*$($d.DeviceName)*" -or ($prefix.Length -gt 6 -and $d.DeviceName -like "*$prefix*"))) {
                            $matchedDev = $d
                            break
                        }
                    }
                }

                $curVer = if ($matchedDev) { $matchedDev.DriverVersion } else { "Windows Update" }
                $hwId = if ($matchedDev -and $matchedDev.HardWareID) {
                    if ($matchedDev.HardWareID -is [array]) { $matchedDev.HardWareID[0] } else { $matchedDev.HardWareID.ToString() }
                } else { "" }
                
                # Extract available version if present in title e.g. (32.0.16.1088)
                $availVer = "Latest WHQL"
                if ($update.Title -match '\(([\d\.]+)\)') {
                    $availVer = $matches[1]
                } elseif ($update.DriverVerDate) {
                    $availVer = (Get-Date $update.DriverVerDate -Format "yyyy.MM.dd")
                }

                # Determine display category
                $catStr = ($categories -join ", ")
                if ($update.DriverClass) {
                    $dClass = $update.DriverClass.ToLower()
                    if ($dClass -like "*video*" -or $dClass -like "*display*") {
                        $catStr = "Grafická karta (GPU)"
                    } elseif ($dClass -like "*net*" -or $dClass -like "*ethernet*" -or $dClass -like "*wi-fi*") {
                        $catStr = "Síťový adaptér (Network)"
                    } elseif ($dClass -like "*system*" -or $dClass -like "*chipset*") {
                        $catStr = "Systémové zařízení (System)"
                    }
                }

                # If the current installed driver version is already equal to or newer than the available update, skip it!
                if ($curVer -and $availVer -and $curVer -ne "Windows Update" -and $availVer -ne "Latest WHQL") {
                    if ($curVer.Trim() -eq $availVer.Trim()) {
                        continue
                    }
                    try {
                        $vCur = [version]$curVer.Trim()
                        $vAvail = [version]$availVer.Trim()
                        if ($vCur.CompareTo($vAvail) -ge 0) {
                            continue
                        }
                    } catch {}
                }

                # Use matched hardware device name if found, otherwise official update title
                $dispTitle = if ($matchedDev) { $matchedDev.DeviceName } else { $update.Title }

                # Translate NVIDIA WDDM driver version (e.g. 32.0.16.2101) to commercial version (e.g. GeForce 621.01)
                $formatNvidiaVer = {
                    param($title, $vStr)
                    if (-not $vStr -or $vStr -eq "Windows Update" -or $vStr -eq "Latest WHQL") { return $vStr }
                    if ($title -match "nvidia|geforce|quadro|rtx|gtx") {
                        $parts = $vStr.Trim().Split('.')
                        if ($parts.Count -eq 4) {
                            $c = $parts[2]
                            $d = $parts[3]
                            if ($c.Length -ge 2 -and ($d.Length -eq 4 -or $d.Length -eq 5)) {
                                $lastC = $c.Substring($c.Length - 1, 1)
                                if ($d.Length -ge 4) {
                                    $major = $lastC + $d.Substring(0, 2)
                                    $minor = $d.Substring(2)
                                    return "$vStr (GeForce $major.$minor)"
                                }
                            }
                        }
                    }
                    return $vStr
                }

                $curVerDisplay = & $formatNvidiaVer $dispTitle $curVer
                $availVerDisplay = & $formatNvidiaVer $dispTitle $availVer

                $isGamingGpu = ($dispTitle -match "nvidia|geforce|rtx|gtx|radeon|rx\s*\d|arc\s*[a-z]\d")
                $gpuVendor = if ($dispTitle -match "nvidia|geforce|rtx|gtx") { "nvidia" } elseif ($dispTitle -match "radeon|amd") { "amd" } elseif ($dispTitle -match "intel|arc") { "intel" } else { "" }

                $updates += [PSCustomObject]@{
                    Title            = $dispTitle
                    UpdateTitle      = $update.Title
                    DriverModel      = $update.DriverModel
                    CurrentVersion   = $curVerDisplay
                    AvailableVersion = $availVerDisplay
                    RawCurrentVersion = $curVer
                    RawAvailableVersion = $availVer
                    ReleaseDate      = (Get-Date -Format "yyyy-MM-dd")
                    Description      = $update.Description
                    IsDriver         = $true
                    Categories       = $catStr
                    KBArticles       = ($update.KBArticleIDs -join ", ")
                    Severity         = $update.MsrcSeverity
                    HardwareId       = $hwId
                    IsSkipped        = $false
                    IsGamingGpu      = $isGamingGpu
                    GpuVendor        = $gpuVendor
                }
            }
        }
    }
} catch {}

# -------------------------------------------------------------
# Online Dedicated GPU Driver Intelligence (NVIDIA GeForce Game Ready)
# -------------------------------------------------------------
try {
    $videoControllers = Get-CimInstance Win32_VideoController | Where-Object { $_.Name }
    foreach ($gpu in $videoControllers) {
        $gpuName = $gpu.Name
        $isNvidia = ($gpuName -match "nvidia|geforce|rtx|gtx")

        if ($isNvidia) {
            $rawVer = $gpu.DriverVersion
            $installedGeForceVer = ""
            if ($rawVer) {
                $parts = $rawVer.Trim().Split('.')
                if ($parts.Count -eq 4) {
                    $c = $parts[2]
                    $d = $parts[3]
                    if ($c.Length -ge 2 -and $d.Length -ge 4) {
                        $major = $c.Substring($c.Length - 1, 1) + $d.Substring(0, 2)
                        $minor = $d.Substring(2)
                        $installedGeForceVer = "$major.$minor"
                    }
                }
            }

            try {
                $nvUrl = "https://gfwsl.geforce.com/services_toolkit/services/com/nvidia/services/AjaxDriverService.php?func=DriverManualLookup&psid=120&pfid=929&osID=57&languageCode=1033&beta=0&isWHQL=1&dch=1"
                $req = [System.Net.HttpWebRequest]::Create($nvUrl)
                $req.UserAgent = "Mozilla/5.0"
                $req.Timeout = 4000
                $resp = $req.GetResponse()
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
                $rawNv = $reader.ReadToEnd()
                $reader.Close()
                $resp.Close()

                $nvJson = $rawNv | ConvertFrom-Json
                if ($nvJson -and $nvJson.IDS -and $nvJson.IDS.Count -gt 0) {
                    $latestNv = $nvJson.IDS[0].downloadInfo
                    $onlineVer = $latestNv.Version
                    $dlUrl = $latestNv.DownloadURL
                    $relDate = $latestNv.ReleaseDateTime

                    $hasVendorUpdate = $false
                    if ($installedGeForceVer -and $onlineVer) {
                        try {
                            $vInst = [version]$installedGeForceVer
                            $vOnline = [version]$onlineVer
                            if ($vOnline.CompareTo($vInst) -gt 0) {
                                $hasVendorUpdate = $true
                            }
                        } catch {
                            if ($onlineVer -ne $installedGeForceVer) { $hasVendorUpdate = $true }
                        }
                    }

                    $foundExisting = $null
                    for ($i = 0; $i -lt $updates.Count; $i++) {
                        $u = $updates[$i]
                        if ($u.Title -like "*$gpuName*" -or $gpuName -like "*$($u.Title)*" -or ($u.GpuVendor -eq "nvidia")) {
                            $foundExisting = $u
                            break
                        }
                    }

                    if ($foundExisting) {
                        $foundExisting.LatestVendorVersion = $onlineVer
                        $foundExisting.VendorDownloadUrl = $dlUrl
                        $foundExisting.VendorReleaseDate = $relDate
                        $foundExisting.VendorDriverType = "Game Ready"
                        $foundExisting.HasVendorUpdate = $hasVendorUpdate
                        $foundExisting.VendorVersionDisplay = "GeForce $onlineVer (Game Ready)"
                    } elseif ($hasVendorUpdate) {
                        $dispCur = if ($installedGeForceVer) { "$rawVer (GeForce $installedGeForceVer)" } else { $rawVer }
                        $updates += [PSCustomObject]@{
                            Title               = $gpuName
                            UpdateTitle         = "NVIDIA GeForce Game Ready Driver $onlineVer"
                            DriverModel         = $gpuName
                            CurrentVersion      = $dispCur
                            AvailableVersion    = "GeForce $onlineVer (Game Ready)"
                            RawCurrentVersion   = $rawVer
                            RawAvailableVersion = $onlineVer
                            ReleaseDate         = (Get-Date -Format "yyyy-MM-dd")
                            Description         = "Oficiální herní Game Ready ovladač přímo od výrobce NVIDIA. Doporučeno pro moderní hry."
                            IsDriver            = $true
                            Categories          = "Grafická karta (GPU)"
                            KBArticles          = "NVIDIA-GRD"
                            Severity            = "Important"
                            HardwareId          = if ($gpu.PNPDeviceID) { $gpu.PNPDeviceID } else { "" }
                            IsSkipped           = $false
                            IsGamingGpu         = $true
                            GpuVendor           = "nvidia"
                            LatestVendorVersion = $onlineVer
                            VendorDownloadUrl   = $dlUrl
                            VendorDriverType    = "Game Ready"
                            HasVendorUpdate     = $true
                            VendorOnly          = $true
                            VendorVersionDisplay= "GeForce $onlineVer (Game Ready)"
                        }
                    }
                }
            } catch {}
        }
    }
} catch {}

# Deduplicate by Title
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
