# root dir
$rootDir = ($Args | Where-Object { $_.StartsWith('--root=') })
if( $rootDir ) {
    $rootDir = $rootDir.Replace('--root=','')
} else {
    $rootDir = "$PSScriptRoot\.."
}

Write-Output 'Check and install module dependencies ...'
if (!(Get-InstalledModule -Name ps12exe -ErrorAction SilentlyContinue)) {
    Write-Verbose 'Installing ps12exe ...'
    Install-Module -Force -SkipPublisherCheck -Repository PSGallery -Scope CurrentUser -Name ps12exe
}

Write-Host "Make aria2c.exe ..."
ps12exe -architecture 'x64' -Localize 'en-US' "$rootDir\aria2c.ps1" "$rootDir\aria2c.exe" | Write-Verbose
