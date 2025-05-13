# Script path
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ # Powershell script
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else
{ # compiled script
    $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}

# --verbose
if ($Args | Where-Object { $_ -in @('--verbose','--console-log-level=debug') }) {
    $VerbosePreference = "Continue"
    Write-Verbose "ScriptPath: $ScriptPath"
}

# --ghproxy
$ghproxy = ($Args | Where-Object { $_.StartsWith('--ghproxy=') }), $env:ARIA2_GHPROXY, $env:GHPROXY | Where-Object { $_ } | Select-Object -First 1 
if ($ghproxy) {
    $ghproxy = $ghproxy.Replace('--ghproxy=','').TrimEnd('/')
}
if( $ghproxy ) {
    $ghproxy = $ghproxy.TrimEnd('/') + '/'
    Write-Verbose "GHProyx: $ghproxy" 
}

# --input-file
$inputFile = ($Args | Where-Object { $_.StartsWith('--input-file=') })
if( $ghproxy -and $inputFile) {
    if( $inputFile ) {
        $inputFile=$inputFile.Replace('--input-file=','')
        if( Test-Path $inputFile ) {
            $oldContext = Get-Content $inputFile
            $newContent = $oldContext -replace '^https://github.com/', "$ghproxy/https://github.com/"
            $newContent = $newContent -replace '^https://raw.githubusercontent.com/', "$ghproxy/https://raw.githubusercontent.com/"
            if( $newContent -ne $oldContext ) {
                Write-Verbose "Trigger ghproxy replace..."
                Set-Content -Path $inputFile -Value $newContent
            }
        }
    }
}

# Source aria2c.exe
$source = "$ScriptPath\source"
if (!(Test-Path $source)) { . "$ScriptPath\lib\download.ps1" --root="$ScriptPath" -GHproxy="$ghproxy"}
if (!(Test-Path $source)) { throw "Download error" }

$Aria2 = "$source\aria2c.exe"
if (!(Test-Path $Aria2)) { . "$ScriptPath\lib\ps122exe.ps1" --root="$ScriptPath" }

# Args filter
$Args = ($Args  | Where-Object { $_ -ne '--verbose' } | Where-Object { !$_.StartsWith('--ghproxy=') } | Where-Object { !$_.StartsWith('--user-agent=') })

# Invoke-Command
Invoke-Command ([scriptblock]::Create("& '$Aria2' $($Args -join ' ')"))
if (-Not $?) {
    Write-Verbose "$Aria2 $($Args -join " ")"
}
