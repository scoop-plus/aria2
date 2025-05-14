<#
.SYNOPSIS
    ghproxy test & config
.DESCRIPTION
    ghproxy test and config
.PARAMETER Uri
    Uri config for ghproxy.result
.EXAMPLE
    .\ghproxy.ps1
    .\ghproxy.ps1 -Uri
#>

[CmdletBinding()]
param(
    [Uri] $Uri
)


function Test-CommandAvailable {
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $Command
    )
    return [Boolean](Get-Command $Command -ErrorAction SilentlyContinue)
}

# Get the config form file
$ghfile = Convert-Path "$PSScriptRoot\ghproxy.json"
$ghproxy = Get-Content $ghfile | ConvertFrom-Json

if ( $Uri ) {
    $ghproxy.result = $Uri.ToString()
    Write-Host "[*] config ghproxy: $($ghproxy.result)"
} else {
    # Test list
    $ghproxy.test = @()
    $ghproxy.list | ForEach-Object {
        $res = Test-NetConnection ($_ -replace '^http[s]?://(.+?)[/]?$','$1')
        if( $res.PingSucceeded ) {
            $ghproxy.test += @{
                url= $_
                latency=$res.PingReplyDetails.RoundtripTime
            }
        }
    }
    Write-Host "[*] faster ghproxy: $($ghproxy.result)"
    # Result
    $ghproxy.result = ($ghproxy.test | Sort-Object -Property latency | Select-Object -First 1).url.TrimEnd('/') + '/'
}

# Update
$ghproxy.update_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ghproxy | ConvertTo-Json | Set-Content -Path $ghfile 


# Auto scoop config
if (Test-CommandAvailable('scoop')) {
    Write-Host "[*] scoop config" 
    $scoopConfig = $(scoop config aria2-options)
    $aria2Options = "--ghproxy='$($ghproxy.result)'"
    if( $scoopConfig ) {
        if( $scoopConfig -match '--ghproxy=' ) {
            $scoopConfig = $scoopConfig -replace '--ghproxy=([^\s]+)',$aria2Options
        } else {
            $scoopConfig += " $aria2Options" 
        }
    } else {
        $scoopConfig = $aria2Options 
    }
    scoop config aria2-options $scoopConfig
}

# Auto git config
if (Test-CommandAvailable('git')) {
    git config list | findstr ".insteadof=https://github.com/" | Foreach-Object { git config --global --unset $_.Replace('.insteadof=https://github.com/','.insteadof') }
    git config --global url."https://github.com/".insteadOf github://
    git config --global url."$($ghproxy.result)https://github.com/".insteadOf https://github.com/
    Write-Host "[*] git config"
    git config list | findstr "github" | Write-Host
} 

