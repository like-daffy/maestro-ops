# =============================================================================
# Maestro Ops - Windows first-time setup
# =============================================================================
# Purpose:
#   First-time setup for a Windows PC that will run Maestro Ops. Performs two
#   independent steps, each safe to re-run (idempotent):
#
#     1) Firewall:
#        Open Windows Defender Firewall inbound TCP ports for Redis (6379)
#        and the FileServer (8100) so Listener PCs on the LAN can connect to
#        this machine when it is acting as the Main PC.
#
#     2) USB/RNDIS adapter metric patch:
#        When an Android device is plugged into the PC, Windows may prefer the
#        phone's "Remote NDIS" / USB-tethering adapter over the real
#        Wi-Fi/Ethernet NIC for 192.168.x.x traffic. Redis connections to the
#        Main PC then time out (~29s) even though the LAN is fine. Bumps the
#        InterfaceMetric on any USB/RNDIS adapter to 9999 so Windows always
#        prefers the real NIC for LAN traffic. Persists across reboots.
#
# Usage (from an elevated PowerShell, or just double-click - it self-elevates):
#   .\setup_win.ps1
# =============================================================================

[CmdletBinding()]
param()

# -- Self-elevate to Administrator --------------------------------------------
$currentUser = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Not running as Administrator - re-launching elevated..." -ForegroundColor Yellow
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process -FilePath 'powershell.exe' -Verb RunAs `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath)
    exit
}

Write-Host ""
Write-Host "=== Maestro Ops: Windows first-time setup ===" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1 -- Firewall: open inbound ports 6379 (Redis) and 8100 (FileServer)
# =============================================================================
# NOTE (Maintenance): Using New-NetFirewallRule (NetSecurity module) rather
# than legacy `netsh advfirewall` because it exposes structured objects we can
# query for idempotency. If a rule with the same DisplayName already exists
# we skip it so re-running this script is always safe.
# =============================================================================
Write-Host "[1/2] Firewall: opening inbound ports 6379 and 8100..." -ForegroundColor Cyan

$firewallRules = @(
    @{ DisplayName = "Maestro Ops Redis";      LocalPort = 6379 },
    @{ DisplayName = "Maestro Ops FileServer"; LocalPort = 8100 }
)

foreach ($rule in $firewallRules) {
    $existing = Get-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host ("  skip  '{0}' already exists (port {1})" -f $rule.DisplayName, $rule.LocalPort) `
                   -ForegroundColor DarkGray
        continue
    }
    try {
        New-NetFirewallRule `
            -DisplayName $rule.DisplayName `
            -Direction Inbound `
            -Action Allow `
            -Protocol TCP `
            -LocalPort $rule.LocalPort `
            -Profile Any `
            -ErrorAction Stop | Out-Null
        Write-Host ("  OK    '{0}' inbound TCP {1} allowed" -f $rule.DisplayName, $rule.LocalPort) `
                   -ForegroundColor Green
    }
    catch {
        Write-Host ("  FAIL  '{0}' (port {1}): {2}" -f $rule.DisplayName, $rule.LocalPort, $_.Exception.Message) `
                   -ForegroundColor Red
    }
}

Write-Host ""

# =============================================================================
# Step 2 -- USB/RNDIS adapter metric patch
# =============================================================================
# NOTE (Maintenance): Matching on InterfaceDescription (driver-reported) rather
# than Name so renaming the adapter in "Network Connections" does not break
# the match. No-op when no phone is currently tethered.
# =============================================================================
Write-Host "[2/2] USB/RNDIS adapter metric patch..." -ForegroundColor Cyan

$usbAdapters = Get-NetAdapter | Where-Object {
    $_.InterfaceDescription -match "Remote NDIS|USB"
}

if (-not $usbAdapters) {
    Write-Host "  skip  no Remote NDIS / USB adapter currently present" -ForegroundColor DarkGray
    Write-Host "        (this is normal if no Android device is plugged in right now)"
    Write-Host ""
    Write-Host "  Adapters currently present:" -ForegroundColor DarkGray
    Get-NetAdapter | Format-Table Name, InterfaceDescription, ifIndex, Status -AutoSize
}
else {
    Write-Host "  Matched USB/RNDIS adapter(s):" -ForegroundColor Green
    $usbAdapters | Format-Table Name, InterfaceDescription, ifIndex, Status -AutoSize

    foreach ($adapter in $usbAdapters) {
        $usbIdx = $adapter.ifIndex
        try {
            Set-NetIPInterface -InterfaceIndex $usbIdx -InterfaceMetric 9999 -ErrorAction Stop
            Write-Host ("  OK    {0} (ifIndex {1}): InterfaceMetric -> 9999" -f $adapter.Name, $usbIdx) `
                       -ForegroundColor Green
        }
        catch {
            Write-Host ("  FAIL  {0} (ifIndex {1}): {2}" -f $adapter.Name, $usbIdx, $_.Exception.Message) `
                       -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=== Setup complete ===" -ForegroundColor Green
Write-Host "  Firewall: ports 6379 (Redis) and 8100 (FileServer) allowed inbound" -ForegroundColor Green
Write-Host "  USB/RNDIS: Windows will prefer the real Wi-Fi/Ethernet NIC for LAN" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
