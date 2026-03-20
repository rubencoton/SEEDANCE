$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$groups = @("RECUPERADO_SIDAM", "ALTERNATIVA_LOCAL_GRATIS")
$rows = @()

foreach ($group in $groups) {
  $groupPath = Join-Path $repoRoot $group
  if (-not (Test-Path $groupPath)) {
    continue
  }

  Get-ChildItem $groupPath -Directory | ForEach-Object {
    $dir = $_.FullName
    $fileCount = (Get-ChildItem $dir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    $sizeBytes = (Get-ChildItem $dir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    if (-not $sizeBytes) { $sizeBytes = 0 }
    $sizeMB = [math]::Round($sizeBytes / 1MB, 2)

    $remote = ""
    $head = ""
    try { $remote = (git -C $dir remote get-url origin) } catch {}
    try { $head = (git -C $dir rev-parse --short HEAD) } catch {}

    $rows += [pscustomobject]@{
      Grupo = $group
      Repo = $_.Name
      Archivos = $fileCount
      TamanoMB = $sizeMB
      Head = $head
      Remote = $remote
    }
  }
}

$rows = $rows | Sort-Object Grupo, Repo

$md = @()
$md += "# INVENTARIO LOCAL SIDAM"
$md += ""
$md += "Generado automaticamente: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$md += ""
$md += "| Grupo | Repo | Archivos | Tamano MB | Head | Remote |"
$md += "|---|---|---:|---:|---|---|"

foreach ($row in $rows) {
  $md += "| $($row.Grupo) | $($row.Repo) | $($row.Archivos) | $($row.TamanoMB) | $($row.Head) | $($row.Remote) |"
}

$outPath = Join-Path $repoRoot "docs\INVENTARIO_LOCAL_SIDAM.md"
$md -join "`n" | Set-Content -Encoding UTF8 $outPath

Write-Host "Inventario generado en: $outPath"
