function Write-SetupInfo {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "[setup] $Message"
}

function Write-SetupWarn {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "[setup] warning: $Message"
}

function Get-WorkstationPlatform {
    if ($IsWindows -or $Env:OS -eq 'Windows_NT') { return 'windows' }
    if ($IsMacOS) { return 'macos' }
    if ($IsLinux) { return 'linux' }
    return 'unknown'
}

function Test-WindowsProcessElevated {
    if (-not ($IsWindows -or $Env:OS -eq 'Windows_NT')) {
        return $false
    }

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-RequiredPath {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) {
        throw "Missing required path: $Path"
    }
}

function Test-FoundationPhase {
    param([Parameter(Mandatory)][string]$RepoRoot)
    foreach ($relative in @(
        'README.md',
        'PLAN.md',
        'AGENTS.md',
        'docs/architecture.md',
        'docs/implementation-plan.md',
        'docs/provisioning.md',
        'docs/shell.md',
        'config/workstation.example.toml',
        'config/agents.example.toml',
        'config/models.example.toml',
        'scripts/doctor',
        'chezmoi/dot_bashrc',
        'chezmoi/dot_bash_profile'
    )) {
        Test-RequiredPath -Path (Join-Path $RepoRoot $relative)
    }
}

function Get-WindowsMsys2BashPath {
    $roots = @('C:\msys64')
    if ($Env:MSYS2_ROOT) {
        $roots = @($Env:MSYS2_ROOT) + $roots
    }

    foreach ($root in ($roots | Select-Object -Unique)) {
        $candidate = Join-Path $root 'usr\bin\bash.exe'
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Update-ProcessPathFromRegistry {
    if (-not ($IsWindows -or $Env:OS -eq 'Windows_NT')) {
        return
    }

    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @()
    if ($machinePath) { $parts += $machinePath }
    if ($userPath) { $parts += $userPath }
    if ($parts.Count -gt 0) {
        $Env:Path = ($parts -join ';')
    }

    if ($Env:LocalAppData) {
        $windowsApps = Join-Path $Env:LocalAppData 'Microsoft\WindowsApps'
        if ((Test-Path $windowsApps) -and (($Env:Path -split ';') -notcontains $windowsApps)) {
            $Env:Path = "$Env:Path;$windowsApps"
        }
    }
}

function Add-UserPathEntry {
    param([Parameter(Mandatory)][string]$PathEntry)

    if (-not (Test-Path $PathEntry)) {
        return
    }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $entries = @()
    if ($userPath) {
        $entries = $userPath -split ';' | Where-Object { $_ }
    }

    if ($entries -notcontains $PathEntry) {
        Write-SetupInfo "adding to user PATH: $PathEntry"
        $entries += $PathEntry
        [Environment]::SetEnvironmentVariable('Path', ($entries -join ';'), 'User')
    }

    if (($Env:Path -split ';') -notcontains $PathEntry) {
        $Env:Path = "$Env:Path;$PathEntry"
    }
}

function Get-WingetCommand {
    Update-ProcessPathFromRegistry
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        return $winget.Source
    }

    if ($Env:LocalAppData) {
        $alias = Join-Path $Env:LocalAppData 'Microsoft\WindowsApps\winget.exe'
        if (Test-Path $alias) {
            Add-UserPathEntry -PathEntry (Split-Path -Parent $alias)
            return $alias
        }
    }

    return $null
}

function Test-CommandAvailable {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Resolve-InstalledCommand -Name $Name)
}

function Resolve-InstalledCommand {
    param([Parameter(Mandatory)][string]$Name)

    Update-ProcessPathFromRegistry

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidateRoots = @()
    if ($Env:LocalAppData) {
        $candidateRoots += Join-Path $Env:LocalAppData 'Microsoft\WindowsApps'
        $candidateRoots += Join-Path $Env:LocalAppData 'Microsoft\WinGet\Packages'
    }
    if ($Env:ProgramFiles) {
        $candidateRoots += Join-Path $Env:ProgramFiles 'WinGet\Packages'
        $candidateRoots += Join-Path $Env:ProgramFiles 'WezTerm'
        $candidateRoots += Join-Path $Env:ProgramFiles 'Neovim\bin'
        $candidateRoots += Join-Path $Env:ProgramFiles 'Yazi'
        $candidateRoots += Join-Path $Env:ProgramFiles 'AutoHotkey\v2'
        $candidateRoots += Join-Path $Env:ProgramFiles 'AutoHotkey'
    }
    if (${Env:ProgramFiles(x86)}) {
        $candidateRoots += Join-Path ${Env:ProgramFiles(x86)} 'Neovim\bin'
    }
    if (${Env:ProgramFiles(x86)}) {
        $candidateRoots += Join-Path ${Env:ProgramFiles(x86)} 'AutoHotkey\v2'
        $candidateRoots += Join-Path ${Env:ProgramFiles(x86)} 'AutoHotkey'
    }

    foreach ($root in ($candidateRoots | Where-Object { $_ -and (Test-Path $_) })) {
        $match = Get-ChildItem -Path $root -Recurse -Filter $Name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) {
            $parent = Split-Path -Parent $match.FullName
            Add-UserPathEntry -PathEntry $parent
            return $match.FullName
        }
    }

    return $null
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Name,
        [switch]$DryRun
    )

    if ($DryRun) {
        Write-SetupInfo "would install $Name with winget package $Id"
        return
    }

    $winget = Get-WingetCommand
    if (-not $winget) {
        throw "winget is required to install $Name automatically, but winget was not found. Install or repair Microsoft App Installer, then rerun setup."
    }

    Write-SetupInfo "installing $Name with winget package $Id"
    & $winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget failed to install $Name ($Id)."
    }
    Update-ProcessPathFromRegistry
}

function Ensure-WindowsPackageCommand {
    param(
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string]$PackageId,
        [Parameter(Mandatory)][string]$Name,
        [switch]$DryRun
    )

    if (Test-CommandAvailable -Name $Command) {
        Write-SetupInfo "$Name already available"
        return
    }

    Install-WingetPackage -Id $PackageId -Name $Name -DryRun:$DryRun

    if (-not $DryRun -and -not (Test-CommandAvailable -Name $Command)) {
        throw "$Name was installed, but command '$Command' could not be resolved. Open a new PowerShell window and rerun setup."
    }
}

function Ensure-WindowsMsys2Ucrt64 {
    $bash = Get-WindowsMsys2BashPath
    if ($bash) {
        Write-SetupInfo "MSYS2 UCRT64 Bash already available: $bash"
        return $bash
    }

    throw 'MSYS2 is required before Windows shell setup. Install MSYS2 at C:\msys64, open the UCRT64 environment, install required packages with pacman, then rerun setup.'
}

function Ensure-Msys2Ucrt64Packages {
    param(
        [Parameter(Mandatory)][string[]]$Packages,
        [switch]$DryRun
    )

    $bash = Ensure-WindowsMsys2Ucrt64
    $packageArguments = $Packages -join ' '
    if ($DryRun) {
        Write-SetupInfo "would install or verify MSYS2 UCRT64 packages: $packageArguments"
        return
    }

    $previousMsystem = $Env:MSYSTEM
    try {
        $Env:MSYSTEM = 'UCRT64'
        Write-SetupInfo "installing or verifying MSYS2 UCRT64 packages: $packageArguments"
        & $bash --login -c "pacman -S --needed --noconfirm $packageArguments"
        if ($LASTEXITCODE -ne 0) {
            throw "MSYS2 pacman failed while installing: $packageArguments"
        }
    } finally {
        $Env:MSYSTEM = $previousMsystem
    }
}

function Ensure-WindowsPhaseOneTools {
    param([switch]$DryRun)

    # Do not install WSL. Git for Windows may be used only to clone the repository;
    # the configured workstation shell is MSYS2 UCRT64 Bash.
    Ensure-WindowsMsys2Ucrt64 | Out-Null
    if (-not (Test-CommandAvailable -Name 'git.exe')) {
        throw 'Git is required before setup. Install Git for Windows, clone this repository, then rerun setup.'
    }
    Write-SetupInfo 'Git already available'
    Ensure-WindowsPackageCommand -Command 'chezmoi.exe' -PackageId 'twpayne.chezmoi' -Name 'chezmoi' -DryRun:$DryRun
    Ensure-Msys2Ucrt64Packages -Packages @(
        'git',
        'jq',
        'unzip',
        'mingw-w64-ucrt-x86_64-ripgrep',
        'mingw-w64-ucrt-x86_64-fd',
        'mingw-w64-ucrt-x86_64-fzf',
        'mingw-w64-ucrt-x86_64-just',
        'mingw-w64-ucrt-x86_64-starship'
    ) -DryRun:$DryRun
}

function Ensure-WindowsWezTerm {
    param([switch]$DryRun)

    Ensure-WindowsPackageCommand -Command 'wezterm.exe' -PackageId 'wez.wezterm' -Name 'WezTerm' -DryRun:$DryRun
}

function Ensure-WindowsAutoHotkey {
    param([switch]$DryRun)

    Ensure-WindowsPackageCommand -Command 'AutoHotkey64.exe' -PackageId 'AutoHotkey.AutoHotkey' -Name 'AutoHotkey v2' -DryRun:$DryRun
}

function Ensure-WindowsNeovim {
    param([switch]$DryRun)

    Ensure-WindowsPackageCommand -Command 'nvim.exe' -PackageId 'Neovim.Neovim' -Name 'Neovim' -DryRun:$DryRun
}

function Ensure-WindowsYazi {
    param([switch]$DryRun)

    Ensure-WindowsPackageCommand -Command 'yazi.exe' -PackageId 'sxyazi.yazi' -Name 'Yazi' -DryRun:$DryRun
}

function Get-WindowsVowenInstallation {
    $candidates = @()
    if ($Env:LocalAppData) {
        $candidates += Join-Path $Env:LocalAppData 'Programs\Vowen\Vowen.exe'
        $candidates += Join-Path $Env:LocalAppData 'Vowen\Vowen.exe'
    }
    if ($Env:ProgramFiles) {
        $candidates += Join-Path $Env:ProgramFiles 'Vowen\Vowen.exe'
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    foreach ($uninstallKey in @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )) {
        $entry = Get-ItemProperty -Path $uninstallKey -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -match '^Vowen(?:\s|$)' } |
            Select-Object -First 1
        if ($entry) {
            if ($entry.InstallLocation) { return $entry.InstallLocation }
            return $entry.DisplayName
        }
    }

    return $null
}

function Ensure-WindowsVowen {
    param([switch]$Install, [switch]$DryRun)

    $installed = Get-WindowsVowenInstallation
    if ($installed) {
        Write-SetupInfo "Vowen already detected: $installed"
        return
    }

    if (-not $Install) {
        Write-SetupInfo 'Vowen is optional and was not detected. To open its official download page, rerun: ./setup.ps1 -Phase vowen -InstallVowen'
        return
    }

    if ($DryRun) {
        Write-SetupInfo 'would open the official Vowen Windows download page; no installer would be downloaded or run automatically'
        return
    }

    Write-SetupInfo 'opening the official Vowen Windows download page; download, security review, and installation remain manual'
    Start-Process 'https://vowen.ai/windows/download/'
}

function Ensure-WindowsHerdr {
    param([switch]$DryRun)

    # The preview installer writes the user PATH. Refresh this process first so
    # an existing installation is detected without running the installer again.
    Update-ProcessPathFromRegistry

    if (Test-CommandAvailable -Name 'herdr.exe') {
        Write-SetupInfo 'Herdr already available'
        return
    }
    if ($DryRun) {
        Write-SetupInfo 'would install Herdr Windows preview through the official herdr.dev installer'
        return
    }

    # User-approved exception: Herdr has no supported Windows package-manager route.
    # Do not generalize this irm|iex pattern to any other bootstrap dependency.
    Write-SetupInfo 'installing Herdr Windows preview through the official herdr.dev installer'
    Invoke-RestMethod 'https://herdr.dev/install.ps1' | Invoke-Expression
    Update-ProcessPathFromRegistry
    if (-not (Test-CommandAvailable -Name 'herdr.exe')) {
        throw 'Herdr installer completed, but herdr.exe was not found. Open a new PowerShell window and rerun setup.'
    }
}

function Ensure-WindowsAgent {
    param([Parameter(Mandatory)][ValidateSet('pi', 'codex')][string]$Agent, [switch]$DryRun)
    Ensure-WindowsPackageCommand -Command 'node.exe' -PackageId 'OpenJS.NodeJS.LTS' -Name 'Node.js LTS' -DryRun:$DryRun
    if ($DryRun) {
        Write-SetupInfo "would install $Agent with npm"
        if ($Agent -eq 'pi') {
            Write-SetupInfo 'would install Pi plugin: npm:@narumitw/pi-usage'
            Write-SetupInfo 'would install Pi plugin: npm:pi-mcp-adapter'
        }
        return
    }
    $npm = Resolve-InstalledCommand -Name 'npm.cmd'
    $package = if ($Agent -eq 'pi') { '@earendil-works/pi-coding-agent' } else { '@openai/codex' }
    $command = if ($Agent -eq 'pi') { 'pi.cmd' } else { 'codex.cmd' }
    if (Test-CommandAvailable -Name $command) {
        Write-SetupInfo "$Agent already available"
    } else {
        & $npm install -g --ignore-scripts $package
        if ($LASTEXITCODE -ne 0) { throw "npm failed to install $Agent." }
    }
    $agentCommand = Resolve-InstalledCommand -Name $command
    if (-not $agentCommand) { throw "$Agent was installed but command was not found." }
    & $agentCommand --version
    if ($LASTEXITCODE -ne 0) { throw "$Agent was installed but its version check failed." }
    if ($Agent -eq 'pi') {
        foreach ($plugin in @('npm:@narumitw/pi-usage', 'npm:pi-mcp-adapter')) {
            $installedPackages = & $agentCommand list 2>&1
            if ($LASTEXITCODE -ne 0) { throw 'Pi could not list installed packages.' }
            if ($installedPackages -match [regex]::Escape($plugin)) {
                Write-SetupInfo "Pi plugin already available: $plugin"
            } else {
                Write-SetupInfo "installing Pi plugin: $plugin"
                & $agentCommand install $plugin
                if ($LASTEXITCODE -ne 0) { throw "Pi failed to install plugin $plugin." }
            }
        }
    }
}

function Get-WindowsQuakeStartupShortcutPath {
    $startup = [Environment]::GetFolderPath('Startup')
    if (-not $startup) {
        throw 'Could not resolve the per-user Windows Startup folder.'
    }
    return Join-Path $startup 'cross-platform-workstation-quake.lnk'
}

function Register-WindowsQuakeStartup {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    $launcher = Join-Path $RepoRoot 'platform\windows\start-quake.ps1'
    Test-RequiredPath -Path $launcher

    $shortcutPath = Get-WindowsQuakeStartupShortcutPath
    $powershell = Join-Path $Env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    if (-not (Test-Path -LiteralPath $powershell)) {
        $command = Get-Command powershell.exe -ErrorAction SilentlyContinue
        if (-not $command) {
            throw 'powershell.exe was not found; cannot register the Quake startup shortcut.'
        }
        $powershell = $command.Source
    }

    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`""

    if ($DryRun) {
        Write-SetupInfo "would create startup shortcut $shortcutPath -> $powershell $arguments"
        return
    }

    Write-SetupInfo "creating startup shortcut: $shortcutPath"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $shortcutPath) | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $powershell
    $shortcut.Arguments = $arguments
    $shortcut.WorkingDirectory = $RepoRoot
    $shortcut.WindowStyle = 7
    $shortcut.Description = 'Start cross-platform-workstation Quake hotkey adapter'
    $shortcut.Save()
}

function Backup-ChezmoiManagedTargets {
    param(
        [switch]$DryRun
    )

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path $HOME ".workstation-setup-backup\$timestamp"
    $targets = @(
        (Join-Path $HOME '.bashrc'),
        (Join-Path $HOME '.bash_profile'),
        (Join-Path $HOME '.config/workstation'),
        (Join-Path $HOME '.config/wezterm'),
        (Join-Path $HOME '.config/nvim'),
        (Join-Path $HOME '.config/yazi'),
        (Join-Path $HOME '.local/bin/workstation-doctor')
    )

    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target)) {
            continue
        }

        $resolved = Resolve-Path -LiteralPath $target
        $relativeName = ($resolved.Path -replace '^[A-Za-z]:\\', '') -replace '[\\/:*?"<>| ]+', '_'
        $backupTarget = Join-Path $backupRoot $relativeName

        if ($DryRun) {
            Write-SetupInfo "would back up $target to $backupTarget before forced chezmoi apply"
            continue
        }

        Write-SetupInfo "backing up $target to $backupTarget"
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backupTarget) | Out-Null
        if ((Get-Item -LiteralPath $resolved.Path).PSIsContainer) {
            Copy-Item -LiteralPath $resolved.Path -Destination $backupTarget -Recurse -Force
        } else {
            Copy-Item -LiteralPath $resolved.Path -Destination $backupTarget -Force
        }
    }
}

function Write-WorkstationEnv {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    $configDir = Join-Path $HOME '.config\workstation'
    $envFile = Join-Path $configDir 'env.sh'
    $unixRoot = $RepoRoot -replace '\\', '/'

    if ($DryRun) {
        Write-SetupInfo "would write WORKSTATION_REPO_ROOT to $envFile"
        return
    }

    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
    $content = @(
        '# Generated by cross-platform-workstation setup. Do not commit machine-local paths.',
        "export WORKSTATION_REPO_ROOT='$unixRoot'"
    ) -join "`n"
    [System.IO.File]::WriteAllText($envFile, "$content`n", [System.Text.UTF8Encoding]::new($false))
}

function Invoke-ChezmoiApply {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    $source = Join-Path $RepoRoot 'chezmoi'
    Test-RequiredPath -Path $source

    if ($DryRun) {
        Write-SetupInfo "would run: chezmoi init --source `"$source`""
        Backup-ChezmoiManagedTargets -DryRun
        Write-SetupInfo 'would run: chezmoi apply --force'
        return
    }

    $chezmoi = Resolve-InstalledCommand -Name 'chezmoi.exe'
    if (-not $chezmoi) {
        throw 'chezmoi is required before applying dotfiles.'
    }

    Write-SetupInfo "initializing chezmoi source: $source"
    & $chezmoi init --source $source
    if ($LASTEXITCODE -ne 0) {
        throw 'chezmoi init failed.'
    }

    Backup-ChezmoiManagedTargets

    Write-SetupInfo 'applying chezmoi dotfiles with --force'
    & $chezmoi --source $source apply --force
    if ($LASTEXITCODE -ne 0) {
        throw 'chezmoi apply failed.'
    }

    Write-WorkstationEnv -RepoRoot $RepoRoot
}

function Invoke-Msys2Bash {
    param(
        [Parameter(Mandatory)][string]$BashPath,
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string]$WorkingDirectory
    )

    $absoluteWorkingDirectory = [System.IO.Path]::GetFullPath($WorkingDirectory)
    $previousSetupDirectory = $Env:WORKSTATION_SETUP_DIRECTORY
    try {
        $previousMsystem = $Env:MSYSTEM
        $Env:MSYSTEM = 'UCRT64'
        $Env:WORKSTATION_SETUP_DIRECTORY = $absoluteWorkingDirectory
        # --login starts Bash in the user's home directory, so PowerShell's
        # current location is not inherited. Set it explicitly inside Bash.
        & $BashPath --login -c ('cd -- "$WORKSTATION_SETUP_DIRECTORY" && ' + $Command)
        if ($LASTEXITCODE -ne 0) {
            throw "MSYS2 Bash command failed with exit code $LASTEXITCODE`: $Command"
        }
    } finally {
        $Env:MSYSTEM = $previousMsystem
        if ($null -eq $previousSetupDirectory) {
            Remove-Item Env:WORKSTATION_SETUP_DIRECTORY -ErrorAction SilentlyContinue
        } else {
            $Env:WORKSTATION_SETUP_DIRECTORY = $previousSetupDirectory
        }
    }
}

function Invoke-Msys2BashInteractive {
    param(
        [Parameter(Mandatory)][string]$BashPath,
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string]$WorkingDirectory
    )

    $absoluteWorkingDirectory = [System.IO.Path]::GetFullPath($WorkingDirectory)
    $previousSetupDirectory = $Env:WORKSTATION_SETUP_DIRECTORY
    try {
        $previousMsystem = $Env:MSYSTEM
        $Env:MSYSTEM = 'UCRT64'
        $Env:WORKSTATION_SETUP_DIRECTORY = $absoluteWorkingDirectory
        # Interactive login Bash also resets to the home directory.
        & $BashPath --login -i -c ('cd -- "$WORKSTATION_SETUP_DIRECTORY" && ' + $Command)
        if ($LASTEXITCODE -ne 0) {
            throw "Interactive MSYS2 Bash command failed with exit code $LASTEXITCODE`: $Command"
        }
    } finally {
        $Env:MSYSTEM = $previousMsystem
        if ($null -eq $previousSetupDirectory) {
            Remove-Item Env:WORKSTATION_SETUP_DIRECTORY -ErrorAction SilentlyContinue
        } else {
            $Env:WORKSTATION_SETUP_DIRECTORY = $previousSetupDirectory
        }
    }
}

function Invoke-WindowsShellValidation {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    Update-ProcessPathFromRegistry
    $bash = Get-WindowsMsys2BashPath
    if (-not $bash) {
        throw 'MSYS2 UCRT64 Bash was not found for validation.'
    }

    if ($DryRun) {
        Write-SetupInfo 'would run repository tests through MSYS2 UCRT64 Bash'
        Write-SetupInfo 'would run doctor --phase shell through configured interactive MSYS2 UCRT64 Bash'
        return
    }

    Write-SetupInfo 'running repository tests through MSYS2 UCRT64 Bash'
    Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './tests/run.bash'

    Write-SetupInfo 'validating configured interactive MSYS2 UCRT64 Bash shell'
    $validation = @'
set -e
export WORKSTATION_REPO_ROOT="$PWD"
platform-info
doctor --phase shell
native_path=$(winpath "$PWD")
test -n "$native_path"
unix_path=$(unixpath "$native_path")
test -n "$unix_path"
project >/tmp/workstation-project-stub.out 2>&1 && exit 1 || test "$?" -eq 64
agent >/tmp/workstation-agent-stub.out 2>&1 && exit 1 || test "$?" -eq 64
'@
    Invoke-Msys2BashInteractive -BashPath $bash -WorkingDirectory $RepoRoot -Command $validation
}

function Invoke-WindowsWezTermValidation {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    Update-ProcessPathFromRegistry
    $bash = Get-WindowsMsys2BashPath
    if (-not $bash) {
        throw 'MSYS2 UCRT64 Bash was not found for WezTerm validation.'
    }

    if ($DryRun) {
        Write-SetupInfo 'would run doctor --phase wezterm through MSYS2 UCRT64 Bash'
        return
    }

    Write-SetupInfo 'validating WezTerm phase through MSYS2 UCRT64 Bash'
    Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase wezterm'
}

function Invoke-WindowsQuakeValidation {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    Update-ProcessPathFromRegistry
    $bash = Get-WindowsMsys2BashPath
    if (-not $bash) {
        throw 'MSYS2 UCRT64 Bash was not found for Quake validation.'
    }

    if ($DryRun) {
        Write-SetupInfo 'would run doctor --phase quake through MSYS2 UCRT64 Bash'
        return
    }

    Write-SetupInfo 'validating Quake phase through MSYS2 UCRT64 Bash'
    Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase quake'
}

function Invoke-WindowsNeovimValidation {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    Update-ProcessPathFromRegistry
    $bash = Get-WindowsMsys2BashPath
    if (-not $bash) {
        throw 'MSYS2 UCRT64 Bash was not found for Neovim validation.'
    }

    if ($DryRun) {
        Write-SetupInfo 'would run doctor --phase neovim through MSYS2 UCRT64 Bash'
        return
    }

    Write-SetupInfo 'validating Neovim phase through MSYS2 UCRT64 Bash'
    Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase neovim'
}

function Invoke-WindowsYaziValidation {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    Update-ProcessPathFromRegistry
    $bash = Get-WindowsMsys2BashPath
    if (-not $bash) {
        throw 'MSYS2 UCRT64 Bash was not found for Yazi validation.'
    }

    if ($DryRun) {
        Write-SetupInfo 'would run doctor --phase yazi through MSYS2 UCRT64 Bash'
        return
    }

    Write-SetupInfo 'validating Yazi phase through MSYS2 UCRT64 Bash'
    Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase yazi'
}

function Invoke-WindowsVowenValidation {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [switch]$DryRun
    )

    $bash = Get-WindowsMsys2BashPath
    if (-not $bash) {
        throw 'MSYS2 UCRT64 Bash was not found for Vowen detection.'
    }

    if ($DryRun) {
        Write-SetupInfo 'would run doctor --phase vowen through MSYS2 UCRT64 Bash'
        return
    }

    Write-SetupInfo 'checking optional Vowen status through MSYS2 UCRT64 Bash'
    Invoke-Msys2Bash -BashPath $bash -WorkingDirectory $RepoRoot -Command './scripts/doctor --phase vowen'
}

function Test-ShellPhase {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$Platform
    )
    Test-FoundationPhase -RepoRoot $RepoRoot
    if ($Platform -eq 'windows') {
        $bash = Get-WindowsMsys2BashPath
        if (-not $bash -or -not (Test-Path $bash)) {
            throw 'MSYS2 UCRT64 Bash was not found.'
        }
    }
}
