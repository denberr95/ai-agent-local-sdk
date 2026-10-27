<#
install.ps1 - Copia la configurazione OpenCode del team in un repository (Windows).

Uso:   scripts\install.ps1 <directory-progetto> [-Force] [-Profile <nome>]
Copia: AGENTS.md, opencode.jsonc, .opencode\agents, .opencode\commands, .opencode\skills

Con -Profile <nome> legge profiles\<nome>\: i file presenti li' sostituiscono gli omonimi del
kit e, se profile.conf elenca AGENTS, SKILLS o COMMANDS, vengono installati solo quelli. Senza
-Profile il comportamento e' invariato. Profili disponibili: vedi profiles\*\README.md.

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
    # $Profile e' una variabile automatica di PowerShell (percorso del profilo utente):
    # il parametro si chiama ProfileName e l'alias tiene -Profile sulla riga di comando.
    [Alias('Profile')]
    [string]$ProfileName = '',
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve-Path non normalizza '..' sui percorsi UNC (\\wsl.localhost\...): senza GetFullPath
# $KitRoot resta '...\scripts\..' e il Substring piu' avanti taglia 11 caratteri di troppo
# da ogni percorso relativo, cioe' esattamente '\.opencode\'.
$KitRoot = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath)
$script:Created = 0
$script:Unchanged = 0
$script:Updated = 0
$script:Skipped = 0

function Show-Usage {
    return 'Uso: scripts\install.ps1 <directory-progetto> [-Force] [-Profile <nome>]'
}

function Stop-WithError([string]$Message) {
    [Console]::Error.WriteLine("ERRORE: $Message")
    exit 1
}

# Get-ProfileSource <percorso-relativo>
# Restituisce il file del profilo che sostituisce quello del kit, se esiste. La corrispondenza
# toglie il prefisso .opencode/: AGENTS.md -> <profilo>\AGENTS.md, .opencode/commands/x.md ->
# <profilo>\commands\x.md. Stringa vuota significa "usa il file del kit".
function Get-ProfileSource([string]$Relative) {
    if (-not $ProfileDir) { return '' }
    $suffix = ($Relative -replace '^\.opencode/', '') -replace '/', '\'
    $candidate = Join-Path $ProfileDir $suffix
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    return ''
}

function Copy-KitFile([string]$Relative, [string]$SourceOverride = '') {
    $native = $Relative -replace '/', '\'
    $src = if ($SourceOverride) { $SourceOverride } else { Join-Path $KitRoot $native }
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

$ProfileDir = ''
$AgentsFilter = @()
$SkillsFilter = @()
$CommandsFilter = @()
if ($ProfileName) {
    if ($ProfileName -match '[\\/]' -or $ProfileName.StartsWith('.')) {
        Stop-WithError ('nome di profilo non valido: {0}' -f $ProfileName)
    }
    $ProfileDir = Join-Path (Join-Path $KitRoot 'profiles') $ProfileName
    if (-not (Test-Path -LiteralPath $ProfileDir -PathType Container)) {
        Stop-WithError ('profilo non trovato: profiles\{0}' -f $ProfileName)
    }
    $conf = Join-Path $ProfileDir 'profile.conf'
    if (Test-Path -LiteralPath $conf -PathType Leaf) {
        # Lettura senza eseguire il file: si accettano solo le righe NOME="valori".
        foreach ($line in Get-Content -LiteralPath $conf) {
            if ($line -match '^AGENTS="(.*)"\s*$') {
                $AgentsFilter = @($Matches[1] -split '\s+' | Where-Object { $_ })
            }
            elseif ($line -match '^SKILLS="(.*)"\s*$') {
                $SkillsFilter = @($Matches[1] -split '\s+' | Where-Object { $_ })
            }
            elseif ($line -match '^COMMANDS="(.*)"\s*$') {
                $CommandsFilter = @($Matches[1] -split '\s+' | Where-Object { $_ })
            }
        }
    }
}

$Stamp = Get-Date -Format 'yyyyMMddHHmmss'
$Version = (Get-Content -LiteralPath (Join-Path $KitRoot 'VERSION') -TotalCount 1).Trim()

# Get-SelectedPaths <sottodirectory-di-.opencode> <nomi> <File|Directory>
# Senza nomi restituisce tutti i file della sottodirectory, come il profilo predefinito.
function Get-SelectedPaths([string]$Sub, [string[]]$Names, [string]$Kind) {
    $base = Join-Path $KitRoot (Join-Path '.opencode' $Sub)
    $roots = @()
    if (-not $Names -or $Names.Count -eq 0) {
        $roots = @($base)
    }
    else {
        foreach ($name in $Names) {
            $candidate = if ($Kind -eq 'File') { Join-Path $base ($name + '.md') } else { Join-Path $base $name }
            if (-not (Test-Path -LiteralPath $candidate)) {
                Stop-WithError ('non presente nel kit: .opencode\{0}\{1}' -f $Sub, (Split-Path -Leaf $candidate))
            }
            $roots += $candidate
        }
    }
    foreach ($root in $roots) {
        Get-ChildItem -LiteralPath $root -Recurse -Force -File |
            Where-Object { $_.Name -ne '.DS_Store' } |
            ForEach-Object { $_.FullName.Substring($KitRoot.Length).TrimStart('\', '/') -replace '\\', '/' }
    }
}

try {
    $files = @('AGENTS.md', 'opencode.jsonc')
    $files += Get-SelectedPaths 'agents' $AgentsFilter 'File'
    $files += Get-SelectedPaths 'commands' $CommandsFilter 'File'
    $files += Get-SelectedPaths 'skills' $SkillsFilter 'Directory'
    foreach ($relative in ($files | Sort-Object)) {
        Copy-KitFile $relative (Get-ProfileSource $relative)
    }
}
catch {
    Stop-WithError $_.Exception.Message
}

$profileNote = if ($ProfileName) { ' (profilo {0})' -f $ProfileName } else { '' }
[Console]::Out.WriteLine(('Kit {0}{1} in {2}: creati={3} invariati={4} aggiornati={5} saltati={6}' -f $Version, $profileNote, $TargetPath, $script:Created, $script:Unchanged, $script:Updated, $script:Skipped))

if ($script:Skipped -gt 0) {
    [Console]::Out.WriteLine('File saltati: uniscili a mano oppure rilancia con -Force.')
    exit 2
}
exit 0
