Param(
    [Parameter(Mandatory=$true)]
    [string]$UpdateTitle
)

$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()
Write-Output "Searching for target update..."
$searchResult = $updateSearcher.Search("IsInstalled=0")

$targetUpdate = $null
foreach ($update in $searchResult.Updates) {
    if ($update.Title -eq $UpdateTitle) {
        $targetUpdate = $update
        break
    }
}

if ($null -eq $targetUpdate) {
    Write-Error "Update '$UpdateTitle' not found."
    exit 1
}

Write-Output "Found update: $($targetUpdate.Title)"
Write-Output "Starting download..."

$updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
$updatesToInstall.Add($targetUpdate) | Out-Null

$downloader = $updateSession.CreateUpdateDownloader()
$downloader.Updates = $updatesToInstall
$downloadResult = $downloader.Download()

Write-Output "Download complete (Result Code: $($downloadResult.ResultCode)). Starting installation..."

$installer = $updateSession.CreateUpdateInstaller()
$installer.Updates = $updatesToInstall
$installResult = $installer.Install()

Write-Output "Installation complete (Result Code: $($installResult.ResultCode))."
if ($installResult.RebootRequired) {
    Write-Output "SYSTEM_REBOOT_REQUIRED"
}
