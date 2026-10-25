<#
ollama-env.ps1 - Configura le variabili d'ambiente del server Ollama per il kit (Windows).

Uso:    scripts\ollama-env.ps1 [-Check]
Valori: ollama\ollama.env (lo stesso file letto da scripts/ollama-env.sh).

Windows: variabili d'ambiente dell'utente, permanenti; Ollama le legge al riavvio.
-Check mostra i valori attuali e li confronta con quelli del kit, senza modificarli.

Exit code: 0 ok, 1 errore, 2 argomenti non validi, 3 (-Check) valori diversi da quelli del kit.
Compatibile con Windows PowerShell 5.1 e PowerShell 7+.
Versione Linux/macOS: scripts/ollama-env.sh
#>
param(
    [switch]$Check,
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Remaining
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$KitRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$EnvFile = Join-Path (Join-Path $KitRoot 'ollama') 'ollama.env'

function Show-Usage {
    return 'Uso: scripts\ollama-env.ps1 [-Check]'
}

function Stop-WithError([string]$Message) {
    [Console]::Error.WriteLine("ERRORE: $Message")
    exit 1
}

function Write-Line([string]$Text) {
    [Console]::Out.WriteLine($Text)
}

if ($Help) {
    Write-Line (Show-Usage)
    exit 0
}
if ($Remaining) {
    [Console]::Error.WriteLine(('ERRORE: argomento non riconosciuto: {0}' -f ($Remaining -join ' ')))
    [Console]::Error.WriteLine((Show-Usage))
    exit 2
}
if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
    Stop-WithError 'sistema operativo non supportato: su Linux e macOS usa scripts/ollama-env.sh'
}
if (-not (Test-Path -LiteralPath $EnvFile -PathType Leaf)) {
    Stop-WithError ('file non trovato: {0}' -f $EnvFile)
}

$names = @()
$values = @()
foreach ($line in Get-Content -LiteralPath $EnvFile) {
    $text = $line.Trim()
    if (-not $text -or $text.StartsWith('#')) {
        continue
    }
    $parts = $text.Split([char[]]@('='), 2)
    if ($parts.Count -ne 2 -or -not $parts[0].StartsWith('OLLAMA_')) {
        Stop-WithError ('riga non valida in ollama/ollama.env: {0}' -f $text)
    }
    $names += $parts[0]
    $values += $parts[1]
}
if ($names.Count -eq 0) {
    Stop-WithError 'nessuna variabile in ollama/ollama.env'
}

if ($Check) {
    $differences = $false
    for ($i = 0; $i -lt $names.Count; $i++) {
        $current = [Environment]::GetEnvironmentVariable($names[$i], 'User')
        if ($current -eq $values[$i]) {
            Write-Line ('[OK]          {0}={1}' -f $names[$i], $values[$i])
        }
        else {
            Write-Line ("[DIVERSA]     {0}: attuale='{1}' atteso='{2}'" -f $names[$i], $current, $values[$i])
            $differences = $true
        }
    }
    if ($differences) {
        Write-Line 'Valori diversi da quelli del kit: lancia scripts\ollama-env.ps1 senza -Check.'
        exit 3
    }
    exit 0
}

try {
    for ($i = 0; $i -lt $names.Count; $i++) {
        [Environment]::SetEnvironmentVariable($names[$i], $values[$i], 'User')
        Write-Line ('[IMPOSTATA]   {0}={1}' -f $names[$i], $values[$i])
    }
}
catch {
    Stop-WithError $_.Exception.Message
}
Write-Line 'Riavvia Ollama: icona nell''area di notifica > Quit Ollama, poi riaprilo dal menu Start.'
exit 0
