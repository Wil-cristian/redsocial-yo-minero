# Script para reemplazar .withOpacity() deprecated por .withValues(alpha:)
# Uso: .\fix_deprecated_withopacity.ps1

Write-Host "Iniciando reemplazo masivo de .withOpacity() a .withValues(alpha:)" -ForegroundColor Cyan
Write-Host ""

# Buscar todos los archivos .dart en lib/
$dartFiles = Get-ChildItem -Path ".\lib" -Filter "*.dart" -Recurse

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Reemplazar .withOpacity( por .withValues(alpha:
    # Patron: .withOpacity(valor) a .withValues(alpha: valor)
    $content = $content -replace '\.withOpacity\(', '.withValues(alpha: '
    
    if ($content -ne $originalContent) {
        $replacements = ([regex]::Matches($originalContent, '\.withOpacity\(')).Count
        $totalReplacements += $replacements
        $totalFiles++
        
        # Guardar el archivo modificado
        Set-Content -Path $file.FullName -Value $content -NoNewline
        
        Write-Host "OK $($file.Name): $replacements reemplazos" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Completado!" -ForegroundColor Green
Write-Host "   Archivos modificados: $totalFiles" -ForegroundColor Yellow
Write-Host "   Total de reemplazos: $totalReplacements" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta 'flutter pub get' y verifica que todo compile correctamente" -ForegroundColor Cyan
