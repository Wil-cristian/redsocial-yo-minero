import 'dart:io';

/// Script para analizar y encontrar todos los colores que no usan AppColorsUnified
void main() async {
  print('🎨 Analizando colores en el proyecto...\n');

  final Map<String, List<ColorUsage>> colorsByFile = {};
  final Map<String, int> colorStats = {};

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ Directorio lib/ no encontrado');
    return;
  }

  await for (final file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final usages = await _analyzeFile(file);
      if (usages.isNotEmpty) {
        colorsByFile[file.path.replaceAll('lib\\', '')] = usages;
        
        for (final usage in usages) {
          colorStats[usage.type] = (colorStats[usage.type] ?? 0) + 1;
        }
      }
    }
  }

  _printResults(colorsByFile, colorStats);
}

class ColorUsage {
  final String type;
  final String code;
  final int line;

  ColorUsage(this.type, this.code, this.line);
}

Future<List<ColorUsage>> _analyzeFile(File file) async {
  final List<ColorUsage> usages = [];
  final lines = await file.readAsLines();

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineNumber = i + 1;

    // Skip comentarios y imports
    if (line.trim().startsWith('//') || 
        line.trim().startsWith('import') ||
        line.contains('AppColorsUnified')) {
      continue;
    }

    // 1. DashboardColors.*
    if (line.contains('DashboardColors.')) {
      final match = RegExp(r'DashboardColors\.(\w+)').firstMatch(line);
      if (match != null) {
        usages.add(ColorUsage('DashboardColors', match.group(0)!, lineNumber));
      }
    }

    // 2. Colors.* (pero no Colors.transparent)
    if (line.contains('Colors.') && !line.contains('Colors.transparent')) {
      final matches = RegExp(r'Colors\.(\w+)').allMatches(line);
      for (final match in matches) {
        final colorName = match.group(1)!;
        if (colorName != 'transparent') {
          usages.add(ColorUsage('Colors', match.group(0)!, lineNumber));
        }
      }
    }

    // 3. Color(0xFF...) o Color.fromRGBO/Color.fromARGB
    if (line.contains(RegExp(r'Color\s*\('))) {
      final matches = RegExp(r'Color\s*\([^)]+\)').allMatches(line);
      for (final match in matches) {
        usages.add(ColorUsage('Color()', match.group(0)!, lineNumber));
      }
    }

    // 4. Color.fromRGBO o Color.fromARGB
    if (line.contains('Color.from')) {
      final matches = RegExp(r'Color\.from[A-Z]+\([^)]+\)').allMatches(line);
      for (final match in matches) {
        usages.add(ColorUsage('Color.from*', match.group(0)!, lineNumber));
      }
    }

    // 5. Hex colors como 0xFF...
    if (line.contains(RegExp(r'0x[0-9A-Fa-f]{8}'))) {
      final matches = RegExp(r'0x[0-9A-Fa-f]{8}').allMatches(line);
      for (final match in matches) {
        usages.add(ColorUsage('Hex Color', match.group(0)!, lineNumber));
      }
    }

    // 6. MaterialColor, MaterialAccentColor
    if (line.contains('MaterialColor') || line.contains('MaterialAccentColor')) {
      usages.add(ColorUsage('MaterialColor', 'MaterialColor declaration', lineNumber));
    }

    // 7. ColorScheme
    if (line.contains('ColorScheme')) {
      usages.add(ColorUsage('ColorScheme', 'ColorScheme usage', lineNumber));
    }

    // 8. ThemeData colors
    if (line.contains('primaryColor:') || 
        line.contains('backgroundColor:') ||
        line.contains('scaffoldBackgroundColor:')) {
      usages.add(ColorUsage('ThemeData', 'Theme color property', lineNumber));
    }
  }

  return usages;
}

void _printResults(Map<String, List<ColorUsage>> colorsByFile, Map<String, int> colorStats) {
  print('═══════════════════════════════════════════════════════');
  print('📊 RESUMEN DE COLORES NO-UNIFIED');
  print('═══════════════════════════════════════════════════════\n');

  // Estadísticas generales
  print('📈 ESTADÍSTICAS GENERALES:\n');
  final sortedStats = colorStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  int total = 0;
  for (final entry in sortedStats) {
    print('  ${entry.key.padRight(20)} : ${entry.value} usos');
    total += entry.value;
  }
  print('\n  ${'TOTAL'.padRight(20)} : $total usos');
  print('\n═══════════════════════════════════════════════════════\n');

  // Archivos con más problemas
  print('🔥 TOP 10 ARCHIVOS CON MÁS COLORES NO-UNIFIED:\n');
  final sortedFiles = colorsByFile.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  
  for (int i = 0; i < sortedFiles.length && i < 10; i++) {
    final entry = sortedFiles[i];
    print('  ${(i + 1).toString().padLeft(2)}. ${entry.key}');
    print('      ${entry.value.length} colores no-unified');
  }

  print('\n═══════════════════════════════════════════════════════\n');

  // Detalles por tipo de color
  print('📋 DETALLES POR TIPO DE COLOR:\n');

  for (final type in sortedStats.map((e) => e.key)) {
    print('▼ $type (${colorStats[type]} usos):');
    print('  ─────────────────────────────────────────────────────');
    
    int count = 0;
    for (final entry in sortedFiles) {
      final typeUsages = entry.value.where((u) => u.type == type).toList();
      if (typeUsages.isNotEmpty && count < 5) {
        print('  📄 ${entry.key}:');
        for (final usage in typeUsages.take(3)) {
          print('     Línea ${usage.line}: ${usage.code}');
        }
        if (typeUsages.length > 3) {
          print('     ... y ${typeUsages.length - 3} más');
        }
        count++;
      }
    }
    print('');
  }

  print('═══════════════════════════════════════════════════════\n');

  // Lista completa de archivos
  print('📂 LISTA COMPLETA DE ARCHIVOS CON COLORES NO-UNIFIED:\n');
  
  for (final entry in sortedFiles) {
    print('${entry.key} (${entry.value.length} usos)');
    
    // Agrupar por tipo
    final byType = <String, List<ColorUsage>>{};
    for (final usage in entry.value) {
      byType.putIfAbsent(usage.type, () => []).add(usage);
    }
    
    for (final type in byType.keys) {
      print('  ├─ $type: ${byType[type]!.length} usos');
      for (final usage in byType[type]!.take(2)) {
        print('  │  └─ Línea ${usage.line}: ${usage.code}');
      }
      if (byType[type]!.length > 2) {
        print('  │     ... y ${byType[type]!.length - 2} más');
      }
    }
    print('');
  }

  print('═══════════════════════════════════════════════════════');
  print('\n✅ Análisis completado!');
  print('📁 Archivos analizados: ${colorsByFile.length}');
  print('🎨 Total colores no-unified: $total');
  print('\n💡 Recomendación: Migrar estos colores a AppColorsUnified');
  print('═══════════════════════════════════════════════════════\n');
}
