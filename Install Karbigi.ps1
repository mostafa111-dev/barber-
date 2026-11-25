param([string]$InstallPath=(Join-Path $env:LOCALAPPDATA 'Karbigi'),[switch]$NoLaunch,[switch]$NoShortcut)
$ErrorActionPreference='Stop'
$runtime=Join-Path $PSScriptRoot 'Karbigi-Desktop'
if(-not (Test-Path -LiteralPath (Join-Path $runtime 'Karbigi.exe'))){$runtime=Join-Path $PSScriptRoot 'Portable\Karbigi-Desktop'}
if(-not (Test-Path -LiteralPath (Join-Path $runtime 'Karbigi.exe'))){throw 'Karbigi-Desktop runtime is missing'}
New-Item -ItemType Directory -Path $InstallPath,(Join-Path $InstallPath 'Database') -Force | Out-Null
foreach($item in Get-ChildItem -LiteralPath $runtime | Where-Object Name -ne 'Database'){
    Copy-Item -LiteralPath $item.FullName -Destination $InstallPath -Recurse -Force
}
$sourceDatabase=Join-Path $PSScriptRoot 'Database'
if(-not (Test-Path -LiteralPath $sourceDatabase)){$sourceDatabase=Join-Path $runtime 'Database'}
foreach($name in @('Database.xlsx','Accounts.json')){
    $from=Join-Path $sourceDatabase $name
    $to=Join-Path (Join-Path $InstallPath 'Database') $name
    if((Test-Path -LiteralPath $from) -and -not (Test-Path -LiteralPath $to)){Copy-Item -LiteralPath $from -Destination $to}
}
foreach($name in @('Install Karbigi.cmd','Install Karbigi.ps1','Create Transfer Package.cmd','Create Transfer Package.ps1','START_HERE.txt')){
    $file=Join-Path $PSScriptRoot $name
    if((Test-Path -LiteralPath $file) -and $PSScriptRoot -ne $InstallPath){Copy-Item -LiteralPath $file -Destination (Join-Path $InstallPath $name) -Force}
}
if(Test-Path -LiteralPath (Join-Path $PSScriptRoot 'Guides')){
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Guides') -Destination $InstallPath -Recurse -Force
}
if(-not $NoShortcut){
    $desktop=[Environment]::GetFolderPath('Desktop')
    $temporary=Join-Path $desktop 'Karbigi.lnk'
    $arabic=Join-Path $desktop 'كربيجي.lnk'
    $shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut($temporary)
    $shortcut.TargetPath=Join-Path $InstallPath 'Karbigi.exe'
    $shortcut.WorkingDirectory=$InstallPath
    $shortcut.IconLocation=(Join-Path $InstallPath 'Karbigi.exe')+',0'
    $shortcut.Description='Karbigi desktop application'
    $shortcut.Save()
    Move-Item -LiteralPath $temporary -Destination $arabic -Force
}
if(-not $NoLaunch){Start-Process -FilePath (Join-Path $InstallPath 'Karbigi.exe')}
