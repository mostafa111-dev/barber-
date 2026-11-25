$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$edgeCandidates = @(
    (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'),
    (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe')
)
$edge = $edgeCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $edge) { Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Microsoft Edge is required.', 'Halaq Demo') | Out-Null; exit 1 }
$pagePath = (Resolve-Path -LiteralPath (Join-Path $projectRoot 'Application\index.html')).Path
$url = ([System.Uri]::new($pagePath)).AbsoluteUri
$profile = Join-Path $env:LOCALAPPDATA 'HalaqDemoProfile'
$arguments = '--app="{0}" --user-data-dir="{1}" --no-first-run' -f $url, $profile
Start-Process -FilePath $edge -ArgumentList $arguments