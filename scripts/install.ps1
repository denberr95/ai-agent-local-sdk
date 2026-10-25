<#
install.ps1 - Copia la configurazione OpenCode del team in un repository (Windows).

Uso:   scripts\install.ps1 <directory-progetto> [-Force]
Copia: AGENTS.md, opencode.jsonc, .opencode\agents, .opencode\commands, .opencode\skills

I file gia' presenti e diversi vengono saltati. Con -Force vengono sostituiti
dopo averne salvato una copia <file>.bak-<timestamp>. Nessun file viene cancellato.

Exit code: 0 ok, 1 errore, 2 alcuni file saltati.
Compatibile con Windows PowerShell 5.1 e PowerShell 7+.
Versione Linux/macOS: scripts/install.sh
#>
param(
    [Parameter(Position = 0)]
    [string]$Target = '',
    [switch]$Force,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$KitRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$script:Created = 0
$script:Unchanged = 0
$script:Updated = 0
$script:Skipped = 0

function Show-Usage {
    return 'Uso: scripts\install.ps1 <directory-progetto> [-Force]'
}

function Stop-WithError([string]$Message) {
    [Console]::Error.WriteLine("ERRORE: $Message")
    exit 1
}

function Copy-KitFile([string]$Relative) {
    $native = $Relative -replace '/', '\'
    $src = Join-Path $KitRoot $native
    $dest = Join-Path $TargetPath $native

    if (-not (Test-Path -LiteralPath $dest)) {
        $parent = Split-Path -Parent $dest
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -LiteralPath $src -Destination $dest
        [Console]::Out.WriteLine(('[CREATO]      {0}' -f $Relative))
        $script:Created++
    }
    elseif (-not (Test-Path -LiteralPath $dest -PathType Leaf)) {
        Stop-WithError ("esiste ma non e' un file: {0}" -f $Relative)
    }
    elseif ((Get-FileHash -LiteralPath $src).Hash -eq (Get-FileHash -LiteralPath $dest).Hash) {
        $script:Unchanged++
    }
    elseif ($Force) {
        Copy-Item -LiteralPath $dest -Destination ('{0}.bak-{1}' -f $dest, $Stamp)
        Copy-Item -LiteralPath $src -Destination $dest -Force
        [Console]::Out.WriteLine(('[AGGIORNATO]  {0} (copia precedente: .bak-{1})' -f $Relative, $Stamp))
        $script:Updated++
    }
    else {
        [Console]::Out.WriteLine(('[SALTATO]     {0} (diverso dal kit)' -f $Relative))
        $script:Skipped++
    }
}

if ($Help) {
    [Console]::Out.WriteLine((Show-Usage))
    exit 0
}
if (-not $Target) {
    [Console]::Error.WriteLine((Show-Usage))
    Stop-WithError 'directory del progetto mancante'
}
if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Stop-WithError ('directory non trovata: {0}' -f $Target)
}

$TargetPath = (Resolve-Path -LiteralPath $Target).ProviderPath.TrimEnd('\', '/')
if ([string]::Equals($TargetPath, $KitRoot.TrimEnd('\', '/'), [System.StringComparison]::OrdinalIgnoreCase)) {
    Stop-WithError 'la destinazione coincide con il repository del kit'
}

$Stamp = Get-Date -Format 'yyyyMMddHHmmss'
$Version = (Get-Content -LiteralPath (Join-Path $KitRoot 'VERSION') -TotalCount 1).Trim()

$files = @('AGENTS.md', 'opencode.jsonc')
foreach ($dir in @('.opencode\agents', '.opencode\commands', '.opencode\skills')) {
    $found = Get-ChildItem -LiteralPath (Join-Path $KitRoot $dir) -Recurse -Force -File |
        Where-Object { $_.Name -ne '.DS_Store' } |
        ForEach-Object { $_.FullName.Substring($KitRoot.Length).TrimStart('\', '/') -replace '\\', '/' } |
        Sort-Object
    if ($found) {
        $files += $found
    }
}

try {
    foreach ($relative in $files) {
        Copy-KitFile $relative
    }
}
catch {
    Stop-WithError $_.Exception.Message
}

[Console]::Out.WriteLine(('Kit {0} in {1}: creati={2} invariati={3} aggiornati={4} saltati={5}' -f $Version, $TargetPath, $script:Created, $script:Unchanged, $script:Updated, $script:Skipped))

if ($script:Skipped -gt 0) {
    [Console]::Out.WriteLine('File saltati: uniscili a mano oppure rilancia con -Force.')
    exit 2
}
exit 0
