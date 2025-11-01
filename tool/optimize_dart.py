#!/usr/bin/env python3
"""
Script para optimizar archivos Dart grandes eliminando:
- Comentarios innecesarios
- Líneas vacías múltiples consecutivas
- Espaciado excesivo
"""
import re
import sys

def optimize_dart_file(input_path, output_path=None):
    """Optimiza un archivo Dart"""
    if output_path is None:
        output_path = input_path
    
    with open(input_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    optimized_lines = []
    prev_was_empty = False
    in_multiline_comment = False
    
    for line in lines:
        stripped = line.strip()
        
        # Detectar inicio/fin de comentarios multilínea
        if '/*' in line:
            in_multiline_comment = True
        if '*/' in line:
            in_multiline_comment = False
            continue  # Skip la línea con */
        
        # Saltar líneas dentro de comentarios multilínea
        if in_multiline_comment:
            continue
        
        # Saltar comentarios de una sola línea que no sean doc comments
        if stripped.startswith('//') and not stripped.startswith('///'):
            continue
        
        # Reducir múltiples líneas vacías a una sola
        if stripped == '':
            if prev_was_empty:
                continue
            prev_was_empty = True
        else:
            prev_was_empty = False
        
        optimized_lines.append(line)
    
    # Escribir archivo optimizado
    with open(output_path, 'w', encoding='utf-8') as f:
        f.writelines(optimized_lines)
    
    original_count = len(lines)
    optimized_count = len(optimized_lines)
    reduction = original_count - optimized_count
    
    print(f"✅ Optimizado: {input_path}")
    print(f"   Líneas originales: {original_count}")
    print(f"   Líneas optimizadas: {optimized_count}")
    print(f"   Reducción: {reduction} líneas ({reduction/original_count*100:.1f}%)")
    
    return optimized_count

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python optimize_dart.py <archivo.dart>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    optimize_dart_file(file_path)
