#!/usr/bin/env python3
"""
Script para migrar TODOS los colores hardcoded al sistema de 10 colores.
"""

import re
import os
import glob

# Mapeo de Colors.xxx a AppColorsUnified
COLOR_MAPPINGS = {
    # Básicos directos
    r'Colors\.red(?!\.shade)': 'AppColorsUnified.error',
    r'Colors\.green(?!\.shade)': 'AppColorsUnified.success',
    r'Colors\.blue(?!\.shade)': 'AppColorsUnified.companyBlue',
    r'Colors\.orange(?!\.shade)': 'AppColorsUnified.orange',
    r'Colors\.amber(?!\.shade)': 'AppColorsUnified.warning',
    r'Colors\.yellow(?!\.shade)': 'AppColorsUnified.warning',
    
    # Variantes de colores
    r'Colors\.purple(?!\.shade)': 'AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2)',
    r'Colors\.pink(?!\.shade)': 'AppColorsUnified.error',
    r'Colors\.teal(?!\.shade)': 'AppColorsUnified.success',
    r'Colors\.cyan(?!\.shade)': 'AppColorsUnified.companyBlue',
    r'Colors\.indigo(?!\.shade)': 'AppColorsUnified.companyBlue',
    r'Colors\.deepPurple(?!\.shade)': 'AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.3)',
    r'Colors\.deepOrange(?!\.shade)': 'AppColorsUnified.darken(AppColorsUnified.orange, 0.2)',
    
    # Con .shade (necesitamos mapearlos)
    r'Colors\.red\.shade[0-9]+': 'AppColorsUnified.error',
    r'Colors\.green\.shade[0-9]+': 'AppColorsUnified.success',
    r'Colors\.blue\.shade[0-9]+': 'AppColorsUnified.companyBlue',
    r'Colors\.orange\.shade[0-9]+': 'AppColorsUnified.orange',
    r'Colors\.amber\.shade[0-9]+': 'AppColorsUnified.warning',
    r'Colors\.yellow\.shade[0-9]+': 'AppColorsUnified.warning',
    r'Colors\.purple\.shade[0-9]+': 'AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.2)',
    r'Colors\.pink\.shade[0-9]+': 'AppColorsUnified.error',
    r'Colors\.teal\.shade[0-9]+': 'AppColorsUnified.success',
    r'Colors\.cyan\.shade[0-9]+': 'AppColorsUnified.companyBlue',
    r'Colors\.indigo\.shade[0-9]+': 'AppColorsUnified.companyBlue',
    r'Colors\.deepPurple\.shade[0-9]+': 'AppColorsUnified.darken(AppColorsUnified.companyBlue, 0.3)',
    r'Colors\.deepOrange\.shade[0-9]+': 'AppColorsUnified.darken(AppColorsUnified.orange, 0.2)',
}

# Archivos a excluir (sistema de colores)
EXCLUDE_FILES = [
    'app_colors_unified.dart',
    'dashboard_colors.dart',
    'colors.dart',
    'metallic_colors.dart',
]

def migrate_file(filepath):
    """Migra un archivo dart a usar AppColorsUnified."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    changes = 0
    
    # Aplicar mapeos
    for pattern, replacement in COLOR_MAPPINGS.items():
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
    print(f"✨ Migración completada:")
    print(f"   {files_modified} archivos modificados")
    print(f"   {total_changes} colores migrados")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
