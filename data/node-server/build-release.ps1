$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

# Official Windows x64 runtime and SHA-256 from the Node.js security release.
$runtimeVersion = (Get-Content -LiteralPath .node-version -Raw).Trim()
$runtimeHash = 'd702daa815eabbff763c7d3808e235cf031cf2ca70211b56847bc72f51e240e5'
$buildDirectory = Join-Path $PSScriptRoot '.build'
$runtimePath = Join-Path $buildDirectory 'node.exe'
New-Item -ItemType Directory -Force -Path $buildDirectory | Out-Null

if (!(Test-Path -LiteralPath $runtimePath) -or
    (Get-FileHash -LiteralPath $runtimePath -Algorithm SHA256).Hash -ne $runtimeHash) {
    Invoke-WebRequest -UseBasicParsing -Uri "https://nodejs.org/dist/v$runtimeVersion/win-x64/node.exe" -OutFile $runtimePath
}
if ((Get-FileHash -LiteralPath $runtimePath -Algorithm SHA256).Hash -ne $runtimeHash) {
    throw 'Downloaded Node.js binary failed SHA-256 verification.'
}

& $runtimePath build-release.cjs
if ($LASTEXITCODE -ne 0) { throw 'Server build failed.' }
