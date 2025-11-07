#!/usr/bin/env python3
"""
Script para migrar literales Color(0xFF...) al sistema de 10 colores.
"""

import re
import os
import glob

# Mapeo de literales específicos a AppColorsUnified
LITERAL_MAPPINGS = {
    # Nuestros propios colores base
    r'Color\(0xFFD4AF37\)': 'AppColorsUnified.gold',  # Oro exacto
    r'Color\(0xFF10B981\)': 'AppColorsUnified.success',  # Success exacto
    r'Color\(0xFFEF4444\)': 'AppColorsUnified.error',  # Error exacto
    r'Color\(0xFFFF6B35\)': 'AppColorsUnified.orange',  # Orange exacto
    r'Color\(0xFFF8F5EF\)': 'AppColorsUnified.background',  # Background exacto
    r'Color\(0xFF1F2937\)': 'AppColorsUnified.textPrimary',  # TextPrimary exacto
    r'Color\(0xFF6B7280\)': 'AppColorsUnified.textSecondary',  # TextSecondary exacto
    r'Color\(0xFF45B7D1\)': 'AppColorsUnified.companyBlue',  # CompanyBlue exacto
    r'Color\(0xFFF59E0B\)': 'AppColorsUnified.warning',  # Warning exacto
    
    # Similares que podemos mapear
    r'Color\(0xFFFFFFFF\)': 'AppColorsUnified.surface',  # Blanco
    r'Color\(0xFFF5F5F5\)': 'AppColorsUnified.background',  # Casi blanco
    r'Color\(0xFFFFD700\)': 'AppColorsUnified.gold',  # Oro brillante
    r'Color\(0xFFFFA500\)': 'AppColorsUnified.orange',  # Naranja
    r'Color\(0xFF666666\)': 'AppColorsUnified.textSecondary',  # Gris texto
    r'Color\(0xFF999999\)': 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)',  # Gris claro
    r'Color\(0xFF333333\)': 'AppColorsUnified.textPrimary',  # Gris oscuro
    r'Color\(0xFF000000\)': 'AppColorsUnified.textPrimary',  # Negro
    
    # Colores funcionales
    r'Color\(0xFF3B82F6\)': 'AppColorsUnified.companyBlue',  # Azul
    r'Color\(0xFF4ECDC4\)': 'AppColorsUnified.success',  # Verde agua
    r'Color\(0xFF6C63FF\)': 'AppColorsUnified.companyBlue',  # Púrpura → azul
    
    # Variantes de oro/metal
    r'Color\(0xFFC0C0C0\)': 'AppColorsUnified.lighten(AppColorsUnified.gold, 0.3)',  # Plata
    r'Color\(0xFFD4A574\)': 'AppColorsUnified.lighten(AppColorsUnified.gold, 0.1)',  # Oro claro
    r'Color\(0xFFB8935E\)': 'AppColorsUnified.darken(AppColorsUnified.gold, 0.1)',  # Oro oscuro
    r'Color\(0xFFE8E8E8\)': 'AppColorsUnified.lighten(AppColorsUnified.surface, 0.05)',  # Gris muy claro
    
    # Colores premium (gradientes)
    r'Color\(0xFFFFE55C\)': 'AppColorsUnified.lighten(AppColorsUnified.gold, 0.2)',  # Oro brillante
    r'Color\(0xFFE0115F\)': 'AppColorsUnified.error',  # Rosa rojo → error
    r'Color\(0xFF9B111E\)': 'AppColorsUnified.darken(AppColorsUnified.error, 0.2)',  # Rojo oscuro
    r'Color\(0xFFFF6B9D\)': 'AppColorsUnified.lighten(AppColorsUnified.error, 0.2)',  # Rosa claro
    r'Color\(0xFFDA70D6\)': 'AppColorsUnified.lighten(AppColorsUnified.companyBlue, 0.3)',  # Orquídea
    
    # Colores informativos
    r'Color\(0xFF1A1A1A\)': 'AppColorsUnified.textPrimary',  # Negro casi
    r'Color\(0xFFFAFAFA\)': 'AppColorsUnified.surface',  # Casi blanco
}

# Archivos a excluir
EXCLUDE_FILES = [
    'app_colors_unified.dart',
    'dashboard_colors.dart',
    'colors.dart',
    'metallic_colors.dart',
]

def migrate_file(filepath):
    """Migra literales Color(0xFF...) en un archivo."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    changes = 0
    
    # Aplicar mapeos
    for pattern, replacement in LITERAL_MAPPINGS.items():
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            matches = len(re.findall(pattern, content))
            changes += matches
            content = new_content
    
    # Solo escribir si hubo cambios
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return changes
    
    return 0

def main():
    """Ejecuta la migración."""
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    total_changes = 0
    files_modified = 0
    
    for filepath in dart_files:
        # Saltar archivos excluidos
        if any(excluded in filepath for excluded in EXCLUDE_FILES):
            continue
        
        changes = migrate_file(filepath)
        if changes > 0:
            files_modified += 1
            total_changes += changes
            print(f"✅ {filepath}: {changes} cambios")
    
    print(f"\n{'='*60}")
    print(f"✨ Migración de literales completada:")
    print(f"   {files_modified} archivos modificados")
    print(f"   {total_changes} literales migrados")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
