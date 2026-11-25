$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$root=$PSScriptRoot
$runtime=Join-Path $root 'Portable\Karbigi-Desktop'
if(-not (Test-Path -LiteralPath (Join-Path $runtime 'Karbigi.exe'))){$runtime=$root}
if(-not (Test-Path -LiteralPath (Join-Path $runtime 'Karbigi.exe'))){throw 'Build the desktop runtime first'}
$output=Join-Path (Join-Path $root 'Portable') 'Karbigi-Desktop-Transfer.zip'
$buffer=[IO.MemoryStream]::new()
$archive=[IO.Compression.ZipArchive]::new($buffer,[IO.Compression.ZipArchiveMode]::Create,$true)
try{
    $runtimeFiles=if($runtime -eq $root){
        @(Get-ChildItem -LiteralPath $runtime -File | Where-Object { $_.Extension -notin @('.ps1','.cmd','.txt') }) +
        @(Get-ChildItem -LiteralPath (Join-Path $runtime 'resources'),(Join-Path $runtime 'locales') -File -Recurse)
    }else{
        @(Get-ChildItem -LiteralPath $runtime -File -Recurse | Where-Object { $_.FullName -notlike (Join-Path $runtime 'Database\*') })
    }
    foreach($file in $runtimeFiles){
        $relative='Karbigi-Desktop/'+$file.FullName.Substring($runtime.Length+1).Replace('\','/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,$file.FullName,$relative,[IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
    foreach($name in @('Database.xlsx','Accounts.json')){
        $file=Join-Path (Join-Path $root 'Database') $name
        if(Test-Path -LiteralPath $file){[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,$file,'Karbigi-Desktop/Database/'+$name,[IO.Compression.CompressionLevel]::Optimal) | Out-Null}
    }
    foreach($name in @('Install Karbigi.cmd','Install Karbigi.ps1','START_HERE.txt')){
        $file=Join-Path $root $name
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,$file,$name,[IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
    foreach($file in Get-ChildItem -LiteralPath (Join-Path $root 'Guides') -File){
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,$file.FullName,('Guides/'+$file.Name),[IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}finally{$archive.Dispose()}
[IO.File]::WriteAllBytes($output,$buffer.ToArray())
$buffer.Dispose()
Write-Host "Transfer package: $output"
