# Get the config form file
$ghfile = Convert-Path "$PSScriptRoot\ghproxy.json"
$ghproxy = Get-Content $ghfile | ConvertFrom-Json

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

# Result
$ghproxy.result = ($ghproxy.test | Sort-Object -Property latency | Select-Object -First 1).url.TrimEnd('/') + '/'
Write-Host "[*] fast ghproxy: $($ghproxy.result)"

# Update
$ghproxy.update_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ghproxy | ConvertTo-Json | Set-Content -Path $ghfile 

# Auto scoop config
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


# Auto git config
git config list | findstr ".insteadof=https://github.com/" | Foreach-Object { git config --global --unset $_.Replace('.insteadof=https://github.com/','.insteadof') }
git config --global url."https://github.com/".insteadOf github://
git config --global url."$($ghproxy.result)https://github.com/".insteadOf https://github.com/
Write-Host "[*] git config"
git config list | findstr "github" | Write-Host
