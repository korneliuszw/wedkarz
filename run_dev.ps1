[CmdletBinding()]
param(
    [ValidateSet('Both', 'Mobile', 'Chrome')]
    [string]$Target = 'Both'
)

$ErrorActionPreference = 'Stop'
$runChrome = $Target -ne 'Mobile'
$runMobile = $Target -ne 'Chrome'

$flutter = (Get-Command flutter -CommandType Application | Select-Object -First 1).Source
$bun = (Get-Command bun -CommandType Application | Select-Object -First 1).Source
$repoRoot = Split-Path -Parent $PSScriptRoot
$tunnelStatePath = Join-Path $PSScriptRoot '.dart_tool/run_dev_tunnel.json'
$server = Join-Path $repoRoot 'wedkarz-serwer'
$publicPem = Join-Path $server 'data/root-public.pem'
if (!(Test-Path -LiteralPath $publicPem -PathType Leaf)) {
    throw "Inspection public key not found at $publicPem"
}
$rootPoint = & $bun (Join-Path $server 'scripts/inspectionRootPoint.ts') $publicPem
if ($LASTEXITCODE -ne 0 -or $rootPoint -isnot [string] -or $rootPoint -cnotmatch '^[A-Za-z0-9_-]{87}$') {
    throw 'Could not read the P-256 inspection public key.'
}

$devicesJson = & $flutter devices --machine
if ($LASTEXITCODE -ne 0) {
    throw 'Flutter could not list devices.'
}
$devices = ($devicesJson -join "`n") | ConvertFrom-Json
if ($runChrome -and !($devices | Where-Object { $_.id -eq 'chrome' -and $_.isSupported })) {
    throw 'Chrome is unavailable in flutter devices.'
}
if ($runMobile) {
    $android = @($devices | Where-Object {
        $_.isSupported -and $_.targetPlatform -like 'android-*' -and
        (!$env:ANDROID_SERIAL -or $_.id -eq $env:ANDROID_SERIAL)
    })
    if ($android.Count -ne 1) {
        throw 'Connect one Android device or emulator, or set ANDROID_SERIAL to the desired Flutter device ID.'
    }
}

function Start-FlutterRun {
    param([string]$Project, [string[]]$FlutterArguments)

    $tokens = @($flutter) + $FlutterArguments
    $quoted = $tokens | ForEach-Object { "'" + $_.Replace("'", "''") + "'" }
    $command = '& ' + ($quoted -join ' ')
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    Start-Process -FilePath (Get-Process -Id $PID).Path `
        -WorkingDirectory $Project `
        -ArgumentList '-NoProfile', '-NoExit', '-EncodedCommand', $encoded
}

function Start-DevApps {
    param([string]$TunnelUrl)

    $sharedDefines = @(
        "--dart-define=ANGLER_API_URL=http://localhost:3001"
        "--dart-define=INSPECTION_ROOT_PUBLIC_KEY=$rootPoint"
    )
    if ($runChrome) {
        Start-FlutterRun -Project $PSScriptRoot `
            -FlutterArguments (@('run', '-d', 'chrome', '--web-hostname=localhost', '--web-port=7357',
                #'--dart-define=PINGGY_DEV_TUNNEL=true') + $sharedDefines)
                '--dart-define=API_URL=http://localhost:3001') + $sharedDefines)
    }
    $sharedDefines = @(
        "--dart-define=ANGLER_API_URL=$TunnelUrl/angler"
        "--dart-define=INSPECTION_ROOT_PUBLIC_KEY=$rootPoint"
    )
    if ($runMobile) {
        Start-FlutterRun -Project (Join-Path $repoRoot 'aplikacja/zezwolenia-zwiazek-mobile') `
            -FlutterArguments (@('run', '-d', $android[0].id, "--dart-define=API_URL=$TunnelUrl/ranger") + $sharedDefines)
    }
}

$tunnelUrlPattern = 'https://[a-z0-9-]+\.(?:free\.pinggy\.net|run\.pinggy-free\.link|a\.pinggy\.link)'
if ($Target -ne 'Both') {
    $activeUrl = $null
    if (Test-Path -LiteralPath $tunnelStatePath -PathType Leaf) {
        $state = Get-Content -LiteralPath $tunnelStatePath -Raw | ConvertFrom-Json
        $activeTunnel = Get-Process -Id $state.processId -ErrorAction SilentlyContinue
        if ($activeTunnel -and $activeTunnel.StartTime.ToUniversalTime().Ticks.ToString() -eq $state.startedAt -and
            $state.url -match "^$tunnelUrlPattern\z") {
            $activeUrl = $state.url
        }
    }
    if (!$activeUrl) {
        throw 'No active development tunnel found. Run run_dev.ps1 without -Target and keep that window open.'
    }
    Start-DevApps -TunnelUrl $activeUrl
    return
}

$docker = (Get-Command docker -CommandType Application | Select-Object -First 1).Source
$ssh = (Get-Command ssh -CommandType Application | Select-Object -First 1).Source
$token = $env:PINGGY_TOKEN
if (!$token) {
    $secret = Read-Host 'Pinggy tunnel token' -AsSecureString
    $token = [Net.NetworkCredential]::new('', $secret).Password
}
if ($token -cnotmatch '^[A-Za-z0-9_-]+$') {
    throw 'Enter the Pinggy token from the SSH command, before @free.pinggy.io.'
}

$container = $null
$tunnel = $null
$savedTunnelState = $false
$logDir = Join-Path ([IO.Path]::GetTempPath()) ('parseta-dev-' + [guid]::NewGuid())
$stdout = Join-Path $logDir 'ssh.log'
$stderr = Join-Path $logDir 'ssh-error.log'
$null = New-Item -ItemType Directory -Path $logDir

try {
    $config = Join-Path $repoRoot 'Caddyfile.dev'
    $container = & $docker run --detach --rm -p '127.0.0.1:80:80' `
        --mount "type=bind,source=$config,target=/etc/caddy/Caddyfile,readonly" caddy:2
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not start Caddy. Check Docker Desktop and whether port 80 is free.'
    }

    $tunnel = Start-Process -FilePath $ssh -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
        -ArgumentList @('-T', '-p', '443', '-R0:127.0.0.1:80',
            '-o', 'StrictHostKeyChecking=no', '-o', 'ServerAliveInterval=30',
            '-o', 'BatchMode=yes', '-o', 'ExitOnForwardFailure=yes', "$token@free.pinggy.io")

    $tunnelUrl = $null
    $deadline = [DateTime]::UtcNow.AddSeconds(45)
    while (!$tunnelUrl -and !$tunnel.HasExited -and [DateTime]::UtcNow -lt $deadline) {
        $output = (Get-Content -LiteralPath $stdout, $stderr -Raw) -join "`n"
        $match = [regex]::Match($output, "$tunnelUrlPattern(?![a-z0-9.-])", 'IgnoreCase')
        if ($match.Success) { $tunnelUrl = $match.Value }
        if (!$tunnelUrl) { Start-Sleep -Milliseconds 250 }
    }
    if (!$tunnelUrl) {
        throw "Pinggy did not provide an HTTPS URL. See SSH logs in $logDir."
    }

    $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $tunnelStatePath)
    @{
        url = $tunnelUrl
        processId = $tunnel.Id
        startedAt = $tunnel.StartTime.ToUniversalTime().Ticks.ToString()
    } | ConvertTo-Json | Set-Content -LiteralPath $tunnelStatePath
    $savedTunnelState = $true
    Write-Host "Angler API  $tunnelUrl/angler"
    Write-Host "Ranger API  $tunnelUrl/ranger"
    Start-DevApps -TunnelUrl $tunnelUrl

    Write-Host 'Keep this window open. Press Ctrl+C to stop the tunnel and proxy.'
    while (!$tunnel.WaitForExit(1000)) {}
    throw "The Pinggy tunnel closed. Restart run_dev.ps1 to get a new URL. SSH logs are in $logDir."
} finally {
    if ($savedTunnelState) { Remove-Item -LiteralPath $tunnelStatePath -ErrorAction SilentlyContinue }
    if ($tunnel -and !$tunnel.HasExited) { $tunnel.Kill() }
    if ($container) { & $docker stop $container | Out-Null }
}
