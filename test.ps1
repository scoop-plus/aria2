$VerbosePreference = "Continue"

$rootDir = Convert-Path $PSScriptRoot

# Aria2 build
if (!(Test-Path "$PSScriptRoot\source")) { . "$PSScriptRoot\lib\download.ps1" --verbose --root=$rootDir  }

# Aria2 ps12exe
if (!(Test-Path "$PSScriptRoot\aria2c.exe")) { . "$PSScriptRoot\lib\ps12exe.ps1" --verbose --root=$rootDir }

# Scoop dir
if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = Convert-Path (scoop prefix scoop) }
$scoopDir = Convert-Path("$env:SCOOP_HOME\..\..\..")

#  Aria2 scoop dir
$aria2ScoopDir = "$scoopDir\apps\aria2\current"
New-Item -Force -ItemType SymbolicLink -Path "$aria2ScoopDir" -Value $rootDir | Write-Verbose

# Shims dir
$aria2ShimPath = "$scoopDir\shims\ghproxy.ps1"
New-Item -Force -ItemType SymbolicLink -Path $aria2ShimPath -Value "$aria2ScoopDir\ghproxy.ps1" | Write-Verbose
