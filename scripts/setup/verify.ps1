param(
    [ValidateSet('foundation', 'shell', 'all')]
    [string]$Phase = 'shell'
)

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $RepoRoot 'scripts/setup/common.ps1')

$Platform = Get-WorkstationPlatform
if ($Platform -eq 'windows') {
    if ($Phase -eq 'foundation') {
        $bash = Get-WindowsGitBashPath
        if (-not $bash) {
            throw 'Git for Windows Bash was not found.'
        }
        Invoke-GitBash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase foundation'
    } else {
        Invoke-WindowsShellValidation -RepoRoot $RepoRoot
    }
} else {
    throw 'verify.ps1 currently validates the Windows provisioning path only.'
}
