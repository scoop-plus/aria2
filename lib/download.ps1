# root dir
$rootDir = ($Args | Where-Object { $_.StartsWith('--root=') })
if( $rootDir ) {
    $rootDir = $rootDir.Replace('--root=','')
} else {
    $rootDir = "$PSScriptRoot\.."
}

# --ghproxy
$ghproxy = ($Args | Where-Object { $_.StartsWith('--ghproxy=') }), $env:ARIA2_GHPROXY, $env:GHPROXY | Where-Object { $_ } | Select-Object -First 1 
if ($ghproxy) {
    $ghproxy = $ghproxy.Replace('--ghproxy=','').TrimEnd('/')
}
if( $ghproxy ) {
    $ghproxy = $ghproxy.TrimEnd('/') + '/'
}

# Get aria2 release
Write-Host "Get Github latest api ..."
$latest = Invoke-RestMethod -Uri https://api.github.com/repos/aria2/aria2/releases/latest
if (-Not $?) {
    throw 'Api Error'
}

Write-Host "Downloading asset ..."
$x64asset = $latest.assets | Where-Object { $_.browser_download_url -like '*win-64bit*' }
$downloadUrl = $ghproxy+$x64asset.browser_download_url
Write-Verbose $downloadUrl
Invoke-WebRequest -Uri $downloadUrl -OutFile "$rootDir\aria2-win-64bit.zip"

Write-Host "Unzipping downloaded && Move Item ..."
Expand-Archive -Force -Path "$rootDir\aria2-win-64bit.zip" -DestinationPath "$rootDir\source\"
Move-Item -Force -Path "$rootDir\source\*win-64bit*\*" -Destination "$rootDir\source\"

Write-Host "Save to local"
Set-Content -Path "$rootDir\source\.env.build" -Value "last_commit = $(git log -1 --pretty=format:%H)
source_tag = $($latest.tag_name.Replace('release-',''))
build_date = $(Get-Date -Format 'yyyyMMdd')
"
# $latest | ConvertTo-Json -Compress -Depth 4 | Out-File -FilePath "$rootDir\latest.json"

Write-Host "Remove temp res ..."
Remove-Item -Recurse "$rootDir\source\*win-64bit*" 
Remove-Item -Recurse "$rootDir\aria2-win-64bit.zip" 
