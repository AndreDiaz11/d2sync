$ErrorActionPreference = 'Stop'

$framework = Join-Path $env:SystemRoot 'Microsoft.NET\Framework\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
$compressionCore = Join-Path $framework 'System.IO.Compression.dll'
$compression = Join-Path $framework 'System.IO.Compression.FileSystem.dll'
$source = Join-Path $PSScriptRoot 'PortableLauncher.cs'
$icon = Join-Path $PSScriptRoot 'app_icon.ico'
$output = Join-Path $PSScriptRoot 'PortableLauncher.rebuilt.exe'

if (-not (Test-Path -LiteralPath $compiler)) {
    throw 'No se encontró el compilador C# de .NET Framework.'
}

& $compiler /nologo /target:winexe /platform:anycpu /optimize+ `
    "/win32icon:$icon" `
    "/reference:$compressionCore" "/reference:$compression" /reference:System.Windows.Forms.dll `
    "/out:$output" $source

if ($LASTEXITCODE -ne 0) {
    throw "El compilador terminó con código $LASTEXITCODE."
}

Write-Host "Lanzador reconstruido: $output"

