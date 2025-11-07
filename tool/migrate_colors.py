#!/usr/bin/env python3
"""
🎨 Script de Migración Automática de Colores - YoMinero

Reemplaza todos los Color(0xFF...) hardcoded con AppColorsUnified.xxx
Genera reporte detallado de cambios por archivo y módulo

Uso:
  python3 tool/migrate_colors.py --analyze   # Solo analizar, no modificar
  python3 tool/migrate_colors.py --migrate   # Aplicar cambios
  python3 tool/migrate_colors.py --report    # Generar reporte detallado
"""

import re
import os
import sys
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple

# ============================================
# MAPEO DE COLORES HARDCODED → AppColorsUnified
# ============================================

COLOR_MAPPINGS = {
    # NARANJA (Menú Radial, HomePage)
    '0xFFFF6B35': 'AppColorsUnified.orange',
    '0xFFF7931E': 'AppColorsUnified.orangeMedium',
    '0xFFFFB84D': 'AppColorsUnified.orangeLight',
    '0xFFFF9500': 'AppColorsUnified.orangeApple',
    '0xFFE06800': 'AppColorsUnified.orangeDark',
    '0xFFFFAA33': 'AppColorsUnified.orangeBright',
    
    # AZUL EMPRESA
    '0xFF45B7D1': 'AppColorsUnified.companySecondary',
    '0xFF3B82F6': 'AppColorsUnified.companyPrimary',
    '0xFF60A5FA': 'AppColorsUnified.infoLight',
    '0xFF2563EB': 'AppColorsUnified.infoDark',
    
    # ORO
    '0xFFD4AF37': 'AppColorsUnified.gold',
    '0xFFF4E4C1': 'AppColorsUnified.goldLight',
    '0xFFB8941E': 'AppColorsUnified.goldDark',
    '0xFFFFD700': 'AppColorsUnified.goldPure',
    '0xFFFFB800': 'AppColorsUnified.favoriteActive',
    
    # PLATA
    '0xFFC0C0C0': 'AppColorsUnified.silver',
    '0xFFE8E8E8': 'AppColorsUnified.silverLight',
    '0xFFA8A8A8': 'AppColorsUnified.silverDark',
    
    # VERDE (Success, Groups, Emerald)
    '0xFF10B981': 'AppColorsUnified.success',
    '0xFF34D399': 'AppColorsUnified.successLight',
    '0xFF059669': 'AppColorsUnified.successDark',
    '0xFF00D084': 'AppColorsUnified.emerald',
    '0xFF4ADE80': 'AppColorsUnified.emeraldLight',
    '0xFF00875A': 'AppColorsUnified.emeraldDark',
    '0xFF2E7D32': 'AppColorsUnified.success',
    
    # ROJO (Error, Ruby)
    '0xFFDC2626': 'AppColorsUnified.error',
    '0xFFF87171': 'AppColorsUnified.errorLight',
    '0xFFB91C1C': 'AppColorsUnified.errorDark',
    '0xFFC62828': 'AppColorsUnified.error',
    '0xFFEF4444': 'AppColorsUnified.ruby',
    '0xFF7F1D1D': 'AppColorsUnified.rubyDark',
    
    # AMARILLO (Warning)
    '0xFFFBBF24': 'AppColorsUnified.warning',
    '0xFFFDE68A': 'AppColorsUnified.warningLight',
    '0xFFF59E0B': 'AppColorsUnified.warningDark',
    '0xFFFFB300': 'AppColorsUnified.warning',
    
    # AZUL (Info, Sapphire)
    '0xFF0F67B5': 'AppColorsUnified.info',
    '0xFF2563EB': 'AppColorsUnified.sapphire',
    '0xFF93C5FD': 'AppColorsUnified.sapphireLight',
    '0xFF1E3A8A': 'AppColorsUnified.sapphireDark',
    '0xFF1976D2': 'AppColorsUnified.info',
    
    # PÚRPURA (Services, Amethyst)
    '0xFF9F7AEA': 'AppColorsUnified.servicePrimary',
    '0xFF7C3AED': 'AppColorsUnified.amethystDark',
    '0xFF9333EA': 'AppColorsUnified.amethyst',
    '0xFFC084FC': 'AppColorsUnified.amethystLight',
    '0xFF8B5CF6': 'AppColorsUnified.serviceBadge',
    '0xFFB794F6': 'AppColorsUnified.servicePrimary',
    
    # ROSA (Messages)
    '0xFFEC4899': 'AppColorsUnified.messagePrimary',
    '0xFFF472B6': 'AppColorsUnified.companyCardPink',
    '0xFFDB2777': 'AppColorsUnified.employeeBadgePink',
    
    # MARRÓN
    '0xFF8B4513': 'AppColorsUnified.textSecondary',  # Marrón silla → texto
    '0xFFCD7F32': 'AppColorsUnified.profileBadgeBronze',
    '0xFFB87333': 'AppColorsUnified.profileBadgeBronze',
    
    # GRISES Y NEUTROS
    '0xFFFFFFFF': 'AppColorsUnified.white',
    '0xFF000000': 'AppColorsUnified.black',
    '0xFFF8F5EF': 'AppColorsUnified.background',
    '0xFFF2EEE7': 'AppColorsUnified.backgroundAlt',
    '0xFFFAF7F2': 'AppColorsUnified.surfaceAlt',
    '0xFFE5E7EB': 'AppColorsUnified.divider',
    '0xFFD5CBBF': 'AppColorsUnified.outline',
    '0xFF282523': 'AppColorsUnified.textPrimary',
    '0xFF5E574F': 'AppColorsUnified.textSecondary',
    '0xFF9E948B': 'AppColorsUnified.textDisabled',
    '0xFFCBD5E1': 'AppColorsUnified.favoriteInactive',
    '0xFF9CA3AF': 'AppColorsUnified.employeeInactive',
    
    # FONDOS ESPECÍFICOS
    '0xFFFAF6ED': 'AppColorsUnified.productBackground',
    '0xFFF3EBFF': 'AppColorsUnified.serviceBackground',
    '0xFFE6F9F3': 'AppColorsUnified.groupBackground',
    '0xFFFCE7F3': 'AppColorsUnified.messageBackground',
    '0xFFEBF5FF': 'AppColorsUnified.companyBackground',
    '0xFFE4F3E5': 'AppColorsUnified.successContainer',
    '0xFFFCE4E4': 'AppColorsUnified.errorContainer',
    '0xFFFFF6DA': 'AppColorsUnified.warningContainer',
    '0xFFE0F0FA': 'AppColorsUnified.infoContainer',
}

# Patrones de gradientes comunes que deben ser reemplazados
GRADIENT_PATTERNS = {
    # Gradiente naranja del menú radial
    r'LinearGradient\s*\(\s*begin:\s*Alignment\.topLeft,\s*end:\s*Alignment\.bottomRight,\s*colors:\s*\[\s*Color\(0xFFFF6B35\),\s*Color\(0xFFF7931E\),\s*Color\(0xFFFFB84D\)\s*\]': 
        'AppColorsUnified.radialButtonGradient',
    
    # Gradiente oro
    r'LinearGradient\s*\(\s*.*colors:\s*\[\s*Color\(0xFFF4E4C1\),\s*Color\(0xFFD4AF37\),\s*Color\(0xFFB8941E\)\s*\]':
        'AppColorsUnified.goldGradient',
}

class ColorMigrator:
    def __init__(self):
        self.lib_path = Path('lib')
        self.stats = defaultdict(lambda: {'files': set(), 'count': 0})
        self.changes = []
        
    def find_dart_files(self) -> List[Path]:
        """Encuentra todos los archivos .dart en lib/"""
        dart_files = []
        for path in self.lib_path.rglob('*.dart'):
            # Excluir archivos de tema que ya están bien
            if 'theme' not in str(path) or 'app_colors_unified' in str(path):
                dart_files.append(path)
        return dart_files
    
    def analyze_file(self, file_path: Path) -> Dict:
        """Analiza un archivo y detecta colores hardcoded"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Buscar todos los Color(0xFF...)
        color_pattern = r'Color\((0xFF[0-9A-Fa-f]{6})\)'
        matches = re.findall(color_pattern, content)
        
        file_changes = []
        for hex_color in matches:
            if hex_color in COLOR_MAPPINGS:
                replacement = COLOR_MAPPINGS[hex_color]
                file_changes.append({
                    'hex': hex_color,
                    'replacement': replacement,
                    'file': str(file_path)
                })
                
                # Estadísticas
                self.stats[hex_color]['count'] += 1
                self.stats[hex_color]['files'].add(str(file_path))
        
        return {
            'file': file_path,
            'content': content,
            'changes': file_changes,
            'total_colors': len(matches),
            'mapped_colors': len(file_changes)
        }
    
    def migrate_file(self, file_path: Path, dry_run: bool = True) -> Tuple[str, int]:
        """Migra los colores de un archivo"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        changes_made = 0
        
        # Reemplazar colores individuales
        for hex_color, replacement in COLOR_MAPPINGS.items():
            pattern = f'Color\\({hex_color}\\)'
            if re.search(pattern, content):
                content = re.sub(pattern, replacement, content)
                changes_made += content.count(replacement) - original_content.count(replacement)
        
        # Reemplazar gradientes complejos
        for pattern, replacement in GRADIENT_PATTERNS.items():
            if re.search(pattern, content):
                content = re.sub(pattern, replacement, content)
                changes_made += 1
        
        # Agregar import si se hicieron cambios
        if changes_made > 0 and 'AppColorsUnified' in content:
            if "import 'package:yominero/core/theme/app_colors_unified.dart';" not in content:
                # Buscar la última línea de import
                import_lines = [line for line in content.split('\n') if line.startswith('import ')]
                if import_lines:
                    last_import = import_lines[-1]
                    content = content.replace(
                        last_import,
                        last_import + "\nimport 'package:yominero/core/theme/app_colors_unified.dart';"
                    )
                else:
                    # Agregar después de la primera línea
                    lines = content.split('\n')
                    lines.insert(1, "import 'package:yominero/core/theme/app_colors_unified.dart';")
                    content = '\n'.join(lines)
        
        # Escribir archivo si no es dry run
        if not dry_run and content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
        
        return content, changes_made
    
    def generate_report(self, results: List[Dict]) -> str:
        """Genera reporte detallado de la migración"""
        report = []
        report.append("=" * 80)
        report.append("🎨 REPORTE DE MIGRACIÓN DE COLORES - YoMinero")
        report.append("=" * 80)
        report.append("")
        
        # Resumen general
        total_files = len([r for r in results if r['mapped_colors'] > 0])
        total_colors = sum(r['total_colors'] for r in results)
        total_mapped = sum(r['mapped_colors'] for r in results)
        
        report.append(f"📊 RESUMEN GENERAL:")
        report.append(f"  • Archivos analizados: {len(results)}")
        report.append(f"  • Archivos con cambios: {total_files}")
        report.append(f"  • Colores hardcoded encontrados: {total_colors}")
        report.append(f"  • Colores que se migrarán: {total_mapped}")
        report.append(f"  • Colores sin mapeo: {total_colors - total_mapped}")
        report.append("")
        
        # Estadísticas por color
        report.append("📈 COLORES MÁS USADOS:")
        sorted_colors = sorted(self.stats.items(), key=lambda x: x[1]['count'], reverse=True)
        for hex_color, data in sorted_colors[:15]:
            if hex_color in COLOR_MAPPINGS:
                report.append(f"  • {hex_color} → {COLOR_MAPPINGS[hex_color]}")
                report.append(f"    Ocurrencias: {data['count']} en {len(data['files'])} archivo(s)")
        report.append("")
        
        # Archivos con más cambios
        report.append("📁 ARCHIVOS CON MÁS CAMBIOS:")
        files_by_changes = sorted(results, key=lambda x: x['mapped_colors'], reverse=True)
        for result in files_by_changes[:10]:
            if result['mapped_colors'] > 0:
                report.append(f"  • {result['file'].name}")
                report.append(f"    {result['mapped_colors']} colores → AppColorsUnified")
        report.append("")
        
        # Detalles por archivo
        report.append("📝 CAMBIOS DETALLADOS POR ARCHIVO:")
        report.append("-" * 80)
        for result in results:
            if result['changes']:
                report.append(f"\n📄 {result['file']}")
                for change in result['changes']:
                    report.append(f"  ✓ {change['hex']} → {change['replacement']}")
        
        report.append("")
        report.append("=" * 80)
        
        return '\n'.join(report)
    
    def run_analysis(self):
        """Ejecuta análisis completo sin modificar archivos"""
        print("🔍 Analizando archivos Dart...")
        dart_files = self.find_dart_files()
        print(f"   Encontrados {len(dart_files)} archivos\n")
        
        results = []
        for file_path in dart_files:
            result = self.analyze_file(file_path)
            results.append(result)
            if result['mapped_colors'] > 0:
                print(f"✓ {file_path.name}: {result['mapped_colors']} colores")
        
        # Generar y guardar reporte
        report = self.generate_report(results)
        print("\n" + report)
        
        # Guardar reporte en archivo
        with open('COLOR_MIGRATION_REPORT.md', 'w', encoding='utf-8') as f:
            f.write(report)
        
        print("\n💾 Reporte guardado en: COLOR_MIGRATION_REPORT.md")
        print("\n🚀 Para aplicar cambios, ejecuta:")
        print("   python3 tool/migrate_colors.py --migrate")
    
    def run_migration(self):
        """Ejecuta migración real modificando archivos"""
        print("⚠️  INICIANDO MIGRACIÓN DE COLORES...")
        print("   Los archivos serán modificados permanentemente\n")
        
        # Confirmar
        response = input("¿Continuar? (s/N): ")
        if response.lower() != 's':
            print("❌ Migración cancelada")
            return
        
        dart_files = self.find_dart_files()
        migrated_files = 0
        total_changes = 0
        
        for file_path in dart_files:
            content, changes = self.migrate_file(file_path, dry_run=False)
            if changes > 0:
                migrated_files += 1
                total_changes += changes
                print(f"✓ {file_path.name}: {changes} cambios")
        
        print(f"\n✅ MIGRACIÓN COMPLETADA!")
        print(f"   Archivos modificados: {migrated_files}")
        print(f"   Cambios totales: {total_changes}")
        print(f"\n📝 Siguiente paso:")
        print(f"   1. Revisar cambios con: git diff")
        print(f"   2. Ejecutar: flutter build web")
        print(f"   3. Probar la app")

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 tool/migrate_colors.py [--analyze|--migrate|--report]")
        sys.exit(1)
    
    migrator = ColorMigrator()
    
    command = sys.argv[1]
    if command == '--analyze' or command == '--report':
        migrator.run_analysis()
    elif command == '--migrate':
        migrator.run_migration()
    else:
        print(f"Comando desconocido: {command}")
        print("Usa: --analyze, --report, o --migrate")
        sys.exit(1)

if __name__ == '__main__':
    main()
