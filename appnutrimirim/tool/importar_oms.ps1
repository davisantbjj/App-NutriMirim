$ErrorActionPreference = 'Stop'
$revision = 'b776d8a12b1c97369c748b561159fd2ec4f4db58'
$base = "https://raw.githubusercontent.com/WorldHealthOrganization/anthro/$revision"
$destino = Join-Path $PSScriptRoot '../assets/oms'
New-Item -ItemType Directory -Force -Path $destino | Out-Null
$manifesto = [ordered]@{ origem = $base; revisao = $revision; arquivos = @() }
foreach ($nome in @('weianthro', 'lenanthro', 'wflanthro', 'wfhanthro', 'bmianthro')) {
    $url = "$base/data-raw/growthstandards/$nome.txt"
    $arquivo = Join-Path $destino "$nome.txt"
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $arquivo
    $manifesto.arquivos += @{ nome = "$nome.txt"; sha256 = (Get-FileHash -LiteralPath $arquivo -Algorithm SHA256).Hash.ToLower(); url = $url }
}
Invoke-WebRequest -UseBasicParsing -Uri "$base/LICENSE.md" -OutFile (Join-Path $destino 'LICENSE-anthro.md')
$manifesto | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $destino 'origem.json') -Encoding UTF8
Write-Output 'Tabelas OMS importadas com origem e SHA-256.'
