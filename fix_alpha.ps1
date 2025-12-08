$files = Get-ChildItem lib -Recurse -Filter "*.dart"
$fixed = 0
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($content -match '\.withValues\(alpha:') {
        $content = $content -replace '\.withValues\(alpha:\s*([0-9.]+)\)', '.withOpacity($1)'
        [System.IO.File]::WriteAllText($file.FullName, $content)
        Write-Host "Fixed: $($file.Name)"
        $fixed++
    }
}
Write-Host ""
Write-Host "Total fixed: $fixed files"
