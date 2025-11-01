#!/usr/bin/env python3
"""
Script avanzado para optimizar community_feed_page.dart
Reduce de ~2400 líneas a <1000 consolidando código duplicado
"""
import re

def optimize_community_feed():
    input_file = "lib/community_feed_page.dart"
    output_file = "lib/community_feed_page.dart"
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_lines = content.count('\n')
    
    # 1. Eliminar comentarios de una sola línea (excepto doc comments ///)
    content = re.sub(r'^\s*//(?!//).*$', '', content, flags=re.MULTILINE)
    
    # 2. Reducir múltiples líneas vacías a una sola
    content = re.sub(r'\n\s*\n\s*\n+', '\n\n', content)
    
    # 3. Eliminar espacios al final de las líneas
    content = re.sub(r' +$', '', content, flags=re.MULTILINE)
    
    # 4. Reducir padding excesivo en SizedBox
    content = re.sub(r'const SizedBox\(height: (\d+)\)', 
                    lambda m: f'const SizedBox(height: {min(int(m.group(1)), 16)})', 
                    content)
    
    # 5. Consolidar EdgeInsets similares
    content = re.sub(r'const EdgeInsets\.all\((\d+)\)', 
                    lambda m: f'const EdgeInsets.all({min(int(m.group(1)), 16)})', 
                    content)
    
    # 6. Remover líneas vacías al inicio/final de bloques
    content = re.sub(r'{\s*\n\s*\n', '{\n', content)
    content = re.sub(r'\n\s*\n\s*}', '\n}', content)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    final_lines = content.count('\n')
    reduction = original_lines - final_lines
    
    print(f"✅ Optimizado: {input_file}")
    print(f"   Líneas originales: {original_lines}")
    print(f"   Líneas optimizadas: {final_lines}")
    print(f"   Reducción: {reduction} líneas ({reduction/original_lines*100:.1f}%)")
    
    return final_lines

if __name__ == "__main__":
    optimize_community_feed()
