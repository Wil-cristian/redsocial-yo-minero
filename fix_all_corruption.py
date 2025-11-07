#!/usr/bin/env python3
"""
Script completo para reparar TODA la corrupción de sed.
Maneja todos los patrones identificados por el analyzer.
"""

import re
from pathlib import Path

# Todos los archivos Flutter en lib/
def get_all_dart_files():
    """Encuentra todos los archivos .dart en lib/"""
    lib_path = Path("lib")
    return [str(f) for f in lib_path.rglob("*.dart")]

def fix_const_violations(content):
    """
    Remueve 'const' de widgets que usan colores no-constantes.
    Estrategia: buscar bloques const ClassName(...) y ver si contienen
    AppColors/DashboardColors/MetallicColors, remover const si es así.
    """
    lines = content.split('\n')
    fixed_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Buscar líneas que tienen "const" seguido de un constructor
        const_match = re.search(r'(\s*)const\s+(\w+)\(', line)
        
        if const_match:
            indent = const_match.group(1)
            class_name = const_match.group(2)
            
            # Recopilar el bloque completo (hasta encontrar el paréntesis de cierre)
            block = [line]
            paren_count = line.count('(') - line.count(')')
            j = i + 1
            
            while j < len(lines) and paren_count > 0:
                block.append(lines[j])
                paren_count += lines[j].count('(') - lines[j].count(')')
                j += 1
            
            block_text = '\n'.join(block)
            
            # Si el bloque contiene AppColors/DashboardColors/MetallicColors, remover const
            if re.search(r'(AppColors|DashboardColors|MetallicColors)\.', block_text):
                # Remover el const de la primera línea
                line = re.sub(r'\bconst\s+', '', line, count=1)
                fixed_lines.append(line)
                # Agregar el resto del bloque sin cambios
                for k in range(i + 1, j):
                    if k < len(lines):
                        fixed_lines.append(lines[k])
                i = j
                continue
        
        fixed_lines.append(line)
        i += 1
    
    return '\n'.join(fixed_lines)

def fix_texttheme_chains(content):
    """
    Arregla Theme.of(context).textTheme<newline>AppColors.titleSmall
    → Theme.of(context).textTheme.titleSmall
    """
    text_theme_properties = [
        'titleSmall', 'titleMedium', 'titleLarge',
        'bodySmall', 'bodyMedium', 'bodyLarge',
        'headlineSmall', 'headlineMedium', 'headlineLarge',
        'displaySmall', 'displayMedium', 'displayLarge',
        'labelSmall', 'labelMedium', 'labelLarge'
    ]
    
    for prop in text_theme_properties:
        # Pattern: .textTheme seguido de nueva línea y luego AppColors.property
        content = re.sub(
            rf'\.textTheme\s+AppColors\.{prop}',
            rf'.textTheme.{prop}',
            content,
            flags=re.MULTILINE
        )
        
        # Lo mismo con DashboardColors
        content = re.sub(
            rf'\.textTheme\s+DashboardColors\.{prop}',
            rf'.textTheme.{prop}',
            content,
            flags=re.MULTILINE
        )
    
    return content

def fix_orphaned_properties(content):
    """
    Arregla líneas que solo tienen AppColors.titleSmall cuando deberían ser .titleSmall
    """
    text_theme_properties = [
        'titleSmall', 'titleMedium', 'titleLarge',
        'bodySmall', 'bodyMedium', 'bodyLarge',
        'headlineSmall', 'headlineMedium', 'headlineLarge',
        'displaySmall', 'displayMedium', 'displayLarge',
        'labelSmall', 'labelMedium', 'labelLarge'
    ]
    
    for prop in text_theme_properties:
        # Si hay AppColors.property en un contexto que parece ser textTheme
        content = re.sub(
            rf'(\s+)AppColors\.{prop}(\s*[,\?\)])',
            rf'\1.{prop}\2',
            content
        )
    
    return content

def fix_file(filepath):
    """Aplica todas las correcciones a un archivo."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            original = f.read()
        
        content = original
        
        # Aplicar todas las correcciones en orden
        # Primero arreglar textTheme chains y orphaned properties
        content = fix_texttheme_chains(content)
        content = fix_orphaned_properties(content)
        
        # Luego remover const violations (esto puede tomar más tiempo)
        content = fix_const_violations(content)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True, "fixed"
        else:
            return False, "no changes"
            
    except Exception as e:
        return False, f"error: {e}"

def main():
    """Repara todos los archivos Dart."""
    print("🔧 Iniciando reparación COMPLETA de corrupción de sed (v2)...\n")
    
    files = get_all_dart_files()
    print(f"📁 Encontrados {len(files)} archivos .dart\n")
    
    fixed_count = 0
    error_count = 0
    
    for filepath in files:
        success, status = fix_file(filepath)
        if success:
            print(f"✅ {filepath}")
            fixed_count += 1
        elif "error" in status:
            print(f"❌ {filepath}: {status}")
            error_count += 1
    
    print(f"\n✨ Reparación completada:")
    print(f"   - Archivos modificados: {fixed_count}")
    print(f"   - Archivos sin cambios: {len(files) - fixed_count - error_count}")
    print(f"   - Errores: {error_count}")

if __name__ == "__main__":
    main()
