# Phase 1 bootstrap guard. Package installation and startup registration arrive in Phase 2.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Write-Error 'Windows bootstrap is not implemented in Phase 1. Install prerequisites manually; see docs/installation.md.'

