<#
.SYNOPSIS
    Build aria2 for Scoop
.DESCRIPTION
    Build aria2 for scoop witch ghproxy support
.PARAMETER Help
    Show Help
.PARAMETER Clean
    Clean aria2c.exe source release.zip
.PARAMETER Make
    Make aria2c.exe
.PARAMETER Compress
    Compress to release zip
.PARAMETER GHProxy
    Use during download aria2
.EXAMPLE
    .\build.ps1 -Help
    .\build.ps1 -GHProxy https://gh-proxy.com/ -Clean -Make
    .\build.ps1 -GHProxy https://gh-proxy.com/ -Make -Compress
    .\build.ps1 -GHProxy https://gh-proxy.com/ -Make -Verbose
#>

[CmdletBinding()]
param(
    [Switch] $Help,
    [Switch] $Clean,
    [Switch] $Make,
    [Switch] $Compress,
    [Uri] $GHProxy
)

Write-Verbose "PowerShell: $($PSVersionTable.PSVersion)"
$rootDir = Convert-Path "$PSScriptRoot"

# opts
$opts= @("--root='$rootDir'")

# Help
if ($Help) {  Get-Help "$rootDir\$($MyInvocation.MyCommand.Name)"  -Examples ; exit }

# Clean
if ($Clean) {  Invoke-Command ([scriptblock]::Create("& '$rootDir\lib\clean.ps1'  $($opts -join ' ')")) }

# GHProxy
if ($GHProxy) {  $GHProxy = $GHProxy.ToString() }
$GHProxy = $GHProxy, $env:ARIA2_GHPROXY, $env:GHPROXY | Where-Object { $_ } | Select-Object -First 1
if ($GHProxy) { $opts += "--ghproxy='$GHProxy'"; Write-Verbose "GHProxy: $GHProxy" }
# Write-Verbose "$($opts.length) $($opts -join ' ')" ; exit

# download
Invoke-Command ([scriptblock]::Create("& '$rootDir\lib\download.ps1' $($opts -join ' ')"))

# make aria2c.exe
if ($Make) { Invoke-Command ([scriptblock]::Create("& '$rootDir\lib\ps12exe.ps1' $($opts -join ' ')")) }

# compress
if ($Compress) { Invoke-Command ([scriptblock]::Create("& '$rootDir\lib\compress.ps1' $($opts -join ' ')")) }
