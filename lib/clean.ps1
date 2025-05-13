# root dir
$rootDir = ($Args | Where-Object { $_.StartsWith('--root=') })
if( $rootDir ) {
    $rootDir = $rootDir.Replace('--root=','') | Convert-Path
} else {
    $rootDir = "$PSScriptRoot\.." | Convert-Path
}

$Aria2c = "$rootDir\aria2c.exe"
$SourceDir = "$rootDir\source"
$CompressZip = "$rootDir\release.zip"

if( Test-Path $Aria2c ) {
    Write-Verbose "clean exe: $Aria2c"
    Remove-Item -Force $Aria2c
}
if( Test-Path $SourceDir ) {
    Write-Verbose "clean dir: $SourceDir"
    Remove-Item -Force -Recurse $SourceDir
}
if( Test-Path $CompressZip ) {
    Write-Verbose "clean zip: $CompressZip"
    Remove-Item -Force $CompressZip
}
