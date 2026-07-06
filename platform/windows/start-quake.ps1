[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$ScriptPath = Join-Path $PSScriptRoot 'quake-toggle.ahk'
if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Quake AutoHotkey script was not found: $ScriptPath"
}

$candidates = @(
    (Join-Path $Env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe'),
    (Join-Path $Env:ProgramFiles 'AutoHotkey\AutoHotkey64.exe')
)

if (${Env:ProgramFiles(x86)}) {
    $candidates += Join-Path ${Env:ProgramFiles(x86)} 'AutoHotkey\v2\AutoHotkey64.exe'
    $candidates += Join-Path ${Env:ProgramFiles(x86)} 'AutoHotkey\AutoHotkey64.exe'
}

$AutoHotkey = $null
foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
        $AutoHotkey = $candidate
        break
    }
}

if (-not $AutoHotkey) {
    $command = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
    if ($command) {
        $AutoHotkey = $command.Source
    }
}

if (-not $AutoHotkey) {
    throw 'AutoHotkey64.exe was not found. Run setup.ps1 -Phase quake first.'
}

Start-Process -FilePath $AutoHotkey -ArgumentList ('"{0}"' -f $ScriptPath) -WindowStyle Hidden
Write-Host "[quake] started AutoHotkey adapter: $ScriptPath"
