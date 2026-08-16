param(
    [ValidateSet('foundation', 'shell', 'wezterm', 'quake', 'neovim', 'yazi', 'all')]
    [string]$Phase = 'shell'
)

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

$Platform = Get-WorkstationPlatform
if ($Platform -eq 'windows') {
    if ($Phase -eq 'foundation') {
        $bash = Get-WindowsMsys2BashPath
        if (-not $bash) {
            throw 'MSYS2 UCRT64 Bash was not found.'
        }
        Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase foundation'
    } elseif ($Phase -eq 'shell') {
        Invoke-WindowsShellValidation -RepoRoot $RepoRoot
    } elseif ($Phase -eq 'wezterm') {
        Invoke-WindowsWezTermValidation -RepoRoot $RepoRoot
    } elseif ($Phase -eq 'quake') {
        Invoke-WindowsQuakeValidation -RepoRoot $RepoRoot
    } elseif ($Phase -eq 'neovim') {
        Invoke-WindowsNeovimValidation -RepoRoot $RepoRoot
    } elseif ($Phase -eq 'yazi') {
        Invoke-WindowsYaziValidation -RepoRoot $RepoRoot
    } elseif ($Phase -eq 'all') {
        Invoke-WindowsShellValidation -RepoRoot $RepoRoot
        Invoke-WindowsWezTermValidation -RepoRoot $RepoRoot
        Invoke-WindowsQuakeValidation -RepoRoot $RepoRoot
        Invoke-WindowsNeovimValidation -RepoRoot $RepoRoot
        Invoke-WindowsYaziValidation -RepoRoot $RepoRoot
    }
} else {
    throw 'verify.ps1 currently validates the Windows provisioning path only.'
}
