# 🎨 SCANNER DE COLORES HARDCODEADOS - YoMinero
# ================================================
# Detecta TODOS los colores hardcodeados en el proyecto Flutter
# Ignorando archivos generados, documentación y colores legítimos

Write-Host "🔍 Escaneando colores hardcodeados en el proyecto..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$projectRoot = Split-Path -Parent $PSScriptRoot
$libPath = Join-Path $projectRoot "lib"

# Archivos a ignorar (legítimos o documentación)
$ignoreFiles = @(
    "app_colors_unified.dart",  # Este ES la fuente de verdad
    "app_colors.dart",           # Sistema legacy
    "dashboard_colors.dart",     # Sistema legacy
    "*.md",                      # Documentación
    "*.txt",                     # Reportes
    "*.json",                    # Configuración
    "*.yaml"                     # Configuración
)

# Patrones a buscar
$patterns = @{
    "Color_Hex" = "Color\(0x[0-9A-Fa-f]{8}\)"           # Color(0xFFXXXXXX)
    "Colors_Named" = "Colors\.(white|black|grey|red|blue|green|yellow|orange|purple|pink|brown|cyan|indigo|lime|teal|amber|deepOrange|deepPurple|lightBlue|lightGreen)(?!\w)"  # Colors.white, etc
    "Color_fromARGB" = "Color\.fromARGB"                 # Color.fromARGB(...)
    "Color_fromRGBO" = "Color\.fromRGBO"                 # Color.fromRGBO(...)
}

# Resultados
$results = @{}
$totalFiles = 0
$totalColors = 0

# Función para extraer el color hex de una línea
function Get-HexColor {
    param($line)
    if ($line -match '0x([0-9A-Fa-f]{8})') {
        return "#" + $matches[1].Substring(2)  # Quitar el FF del alpha
    }
    return "N/A"
}

# Función para determinar si un archivo debe ignorarse
function Should-IgnoreFile {
    param($fileName)
    foreach ($pattern in $ignoreFiles) {
        if ($fileName -like $pattern) {
            return $true
        }
    }
    return $false
}

# Escanear todos los archivos .dart en lib/
Write-Host "📂 Escaneando directorio: $libPath" -ForegroundColor Yellow
Write-Host ""

Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | ForEach-Object {
    $file = $_
    $fileName = $file.Name
    $relativePath = $file.FullName.Replace($projectRoot + "\", "")
    
    # Ignorar archivos específicos
    if (Should-IgnoreFile $fileName) {
        Write-Host "⏭️  Ignorando: $relativePath (archivo legítimo)" -ForegroundColor DarkGray
        return
    }
    
    $fileResults = @{
        "Color_Hex" = @()
        "Colors_Named" = @()
        "Color_fromARGB" = @()
        "Color_fromRGBO" = @()
    }
    
    $content = Get-Content $file.FullName -Raw
    $lines = Get-Content $file.FullName
    
    # Buscar cada patrón
    foreach ($patternName in $patterns.Keys) {
        $pattern = $patterns[$patternName]
        $matches = [regex]::Matches($content, $pattern)
        
        if ($matches.Count -gt 0) {
            foreach ($match in $matches) {
                # Encontrar número de línea
                $lineNumber = 1
                $position = 0
                foreach ($line in $lines) {
                    $position += $line.Length + 1  # +1 por el newline
                    if ($position -ge $match.Index) {
                        break
                    }
                    $lineNumber++
                }
                
                $hexColor = Get-HexColor $match.Value
                $fileResults[$patternName] += @{
                    "Line" = $lineNumber
                    "Code" = $match.Value
                    "HexColor" = $hexColor
                    "Context" = $lines[$lineNumber - 1].Trim()
                }
            }
        }
    }
    
    # Si encontró colores, agregar a resultados
    $totalFound = ($fileResults.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
    if ($totalFound -gt 0) {
        $results[$relativePath] = $fileResults
        $totalFiles++
        $totalColors += $totalFound
        
        Write-Host "❌ $relativePath" -ForegroundColor Red
        Write-Host "   Colores encontrados: $totalFound" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "📊 RESUMEN DEL ESCANEO" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivos con colores hardcodeados: $totalFiles" -ForegroundColor Yellow
Write-Host "Total de colores hardcodeados: $totalColors" -ForegroundColor Yellow
Write-Host ""

# Generar reporte detallado
$reportPath = Join-Path $projectRoot "SCAN_COLORES_HARDCODEADOS.md"
$report = @"
# 🎨 REPORTE DE COLORES HARDCODEADOS
**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Archivos escaneados:** $(Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | Measure-Object).Count  
**Archivos con problemas:** $totalFiles  
**Total colores hardcodeados:** $totalColors  

---

"@

if ($totalColors -eq 0) {
    $report += @"
## ✅ ¡PROYECTO 100% CENTRALIZADO!

No se encontraron colores hardcodeados en el proyecto.  
Todos los colores están centralizados en **AppColorsUnified**.

🎉 **¡Excelente trabajo!**
"@
} else {
    $report += @"
## ⚠️ ARCHIVOS CON COLORES HARDCODEADOS

Se encontraron **$totalColors colores** en **$totalFiles archivos** que necesitan migración.

---

"@

    # Ordenar por cantidad de colores (de mayor a menor)
    $sortedResults = $results.GetEnumerator() | Sort-Object { 
        ($_.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum 
    } -Descending

    $fileNumber = 1
    foreach ($entry in $sortedResults) {
        $filePath = $entry.Key
        $fileData = $entry.Value
        $fileName = Split-Path $filePath -Leaf
        
        $colorCount = ($fileData.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        
        $report += @"
### $fileNumber. ❌ ``$fileName``
**Ruta:** ``$filePath``  
**Colores hardcodeados:** $colorCount  

"@

        # Colores hexadecimales
        if ($fileData["Color_Hex"].Count -gt 0) {
            $report += "#### 🎨 Colores Hexadecimales (Color(0xFFXXXXXX))`n"
            $report += "| Línea | Color Hex | Código |`n"
            $report += "|-------|-----------|--------|`n"
            foreach ($color in $fileData["Color_Hex"]) {
                $report += "| $($color.Line) | ``$($color.HexColor)`` | ``$($color.Code)`` |`n"
            }
            $report += "`n"
        }
        
        # Colors.named
        if ($fileData["Colors_Named"].Count -gt 0) {
            $report += "#### 🏷️ Colores Named (Colors.white, Colors.black, etc)`n"
            $report += "| Línea | Código |`n"
            $report += "|-------|--------|`n"
            foreach ($color in $fileData["Colors_Named"]) {
                $report += "| $($color.Line) | ``$($color.Code)`` |`n"
            }
            $report += "`n"
        }
        
        # Color.fromARGB
        if ($fileData["Color_fromARGB"].Count -gt 0) {
            $report += "#### 🔢 Color.fromARGB`n"
            $report += "| Línea | Código |`n"
            $report += "|-------|--------|`n"
            foreach ($color in $fileData["Color_fromARGB"]) {
                $report += "| $($color.Line) | ``$($color.Context)`` |`n"
            }
            $report += "`n"
        }
        
        # Color.fromRGBO
        if ($fileData["Color_fromRGBO"].Count -gt 0) {
            $report += "#### 🔢 Color.fromRGBO`n"
            $report += "| Línea | Código |`n"
            $report += "|-------|--------|`n"
            foreach ($color in $fileData["Color_fromRGBO"]) {
                $report += "| $($color.Line) | ``$($color.Context)`` |`n"
            }
            $report += "`n"
        }
        
        $report += "**Recomendaciones de migración:**`n"
        
        # Analizar colores y sugerir reemplazos
        $uniqueColors = $fileData["Color_Hex"] | ForEach-Object { $_.HexColor } | Select-Object -Unique
        foreach ($hexColor in $uniqueColors) {
            $suggestion = switch -Regex ($hexColor) {
                "#D4AF37" { "``AppColorsUnified.gold`` (oro premium 24K)" }
                "#FF8C00" { "``AppColorsUnified.orange`` (naranja vibrante)" }
                "#8B4513" { "``AppColorsUnified.wood`` (madera)" }
                "#B87333" { "``AppColorsUnified.copperDark`` (cobre oscuro)" }
                "#2D2416" { "``AppColorsUnified.charcoal`` (carbón)" }
                "#1A1A1A" { "``AppColorsUnified.textPrimary`` o ``charcoal``" }
                "#FFFFFF" { "``AppColorsUnified.pureWhite`` o ``surface``" }
                "#000000" { "``AppColorsUnified.textPrimary``" }
                "#F[0-9A-F]{5}" { "``AppColorsUnified.background`` o ``grey50``" }
                "#E[0-9A-F]{5}" { "``AppColorsUnified.grey100`` o ``borderLight``" }
                "#[CDE][0-9A-F]{5}" { "``AppColorsUnified.grey200/300``" }
                "#[89AB][0-9A-F]{5}" { "``AppColorsUnified.grey400/500``" }
                "#[4-7][0-9A-F]{5}" { "``AppColorsUnified.grey600/700``" }
                "#[0-3][0-9A-F]{5}" { "``AppColorsUnified.charcoal`` o ``textPrimary``" }
                "#C0C0C0" { "``AppColorsUnified.grey300`` (plata)" }
                "#10B981" { "``AppColorsUnified.success`` (verde)" }
                "#EF4444" { "``AppColorsUnified.error`` (rojo)" }
                "#F59E0B" { "``AppColorsUnified.warning`` (ámbar)" }
                "#2563EB" { "``AppColorsUnified.companyBlue`` (azul royal)" }
                default { "``AppColorsUnified.grey500`` o similar" }
            }
            $report += "- ``$hexColor`` → $suggestion`n"
        }
        
        $report += "`n---`n`n"
        $fileNumber++
    }

    # Priorización
    $report += @"
## 🎯 PRIORIZACIÓN DE MIGRACIÓN

"@

    $priority1 = $sortedResults | Where-Object { 
        $count = ($_.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        $count -ge 20
    }
    
    $priority2 = $sortedResults | Where-Object { 
        $count = ($_.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        $count -ge 10 -and $count -lt 20
    }
    
    $priority3 = $sortedResults | Where-Object { 
        $count = ($_.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        $count -lt 10
    }

    if ($priority1.Count -gt 0) {
        $report += "### 🔥 PRIORIDAD CRÍTICA (20+ colores)`n`n"
        foreach ($entry in $priority1) {
            $count = ($entry.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
            $report += "- ❌ ``$($entry.Key)`` ($count colores)`n"
        }
        $report += "`n"
    }

    if ($priority2.Count -gt 0) {
        $report += "### ⚠️ PRIORIDAD ALTA (10-19 colores)`n`n"
        foreach ($entry in $priority2) {
            $count = ($entry.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
            $report += "- ⚠️ ``$($entry.Key)`` ($count colores)`n"
        }
        $report += "`n"
    }

    if ($priority3.Count -gt 0) {
        $report += "### PRIORIDAD MEDIA (<10 colores)`n`n"
        foreach ($entry in $priority3) {
            $count = ($entry.Value.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
            $report += "- ``$($entry.Key)`` ($count colores)`n"
        }
        $report += "`n"
    }
}

$report += @"

---

## 📋 ESTADÍSTICAS DETALLADAS

| Métrica | Valor |
|---------|-------|
| **Archivos Dart totales** | $(Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | Measure-Object).Count |
| **Archivos con problemas** | $totalFiles |
| **Color(0xFFXXXXXX)** | $(($results.Values | ForEach-Object { $_["Color_Hex"].Count } | Measure-Object -Sum).Sum) |
| **Colors.named** | $(($results.Values | ForEach-Object { $_["Colors_Named"].Count } | Measure-Object -Sum).Sum) |
| **Color.fromARGB** | $(($results.Values | ForEach-Object { $_["Color_fromARGB"].Count } | Measure-Object -Sum).Sum) |
| **Color.fromRGBO** | $(($results.Values | ForEach-Object { $_["Color_fromRGBO"].Count } | Measure-Object -Sum).Sum) |
| **Total colores** | $totalColors |

---

## ✅ PROGRESO DE MIGRACIÓN

**Archivos ya migrados:**
- ✅ ``home_page.dart`` (21 colores)
- ✅ ``chat_page.dart`` (17 colores)
- ✅ ``conversations_page.dart`` (10 colores)
- ✅ ``products_page.dart`` (21 colores)
- ✅ ``services_page.dart`` (21 colores)
- ✅ ``edit_profile_page.dart`` (20 colores)
- ✅ ``custom_side_drawer.dart`` (45+ colores)

**Total migrado anteriormente:** ~155 colores  
**Total pendiente:** $totalColors colores  
**Gran total:** $(155 + $totalColors) colores en todo el proyecto

---

## 🚀 PRÓXIMOS PASOS

1. Migrar archivos de **PRIORIDAD CRÍTICA** primero
2. Continuar con **PRIORIDAD ALTA**
3. Finalizar con **PRIORIDAD MEDIA**
4. Ejecutar ``flutter analyze`` para verificar
5. Hot reload y validación visual

---

**Generado por:** Scanner de Colores Hardcodeados v2.0  
**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

# Guardar reporte
$report | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "✅ Reporte generado:" -ForegroundColor Green
Write-Host "   $reportPath" -ForegroundColor Cyan
Write-Host ""

if ($totalColors -gt 0) {
    Write-Host "⚠️  Se encontraron $totalColors colores hardcodeados en $totalFiles archivos" -ForegroundColor Yellow
    Write-Host "📄 Revisa el reporte para detalles completos y sugerencias de migración" -ForegroundColor Yellow
} else {
    Write-Host "🎉 ¡EXCELENTE! No se encontraron colores hardcodeados" -ForegroundColor Green
    Write-Host "✨ El proyecto está 100% centralizado" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
