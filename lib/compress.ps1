# root dir
$rootDir = ($Args | Where-Object { $_.StartsWith('--root=') })
if( $rootDir ) {
    $rootDir = $rootDir.Replace('--root=','')
} else {
    $rootDir = "$PSScriptRoot\.."
}

$CompressZip = "$rootDir\release.zip"

Write-Host "Compress zip .."
$entries = Get-ChildItem -Path $root -Exclude @('.git*','*.zip')
$entries | Write-Verbose
Compress-Archive -Force -LiteralPath $entries -CompressionLevel Optimal -DestinationPath $CompressZip
