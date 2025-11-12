import 'dart:io';

void main() async {
  print('🔧 Corrigiendo errores finales...\n');
  
  int fixes = 0;
  
  // 1. Agregar imports faltantes
  fixes += await _fixMissingImports();
  
  // 2. Reemplazar propiedades inexistentes
  fixes += await _fixNonExistentProperties();
  
  // 3. Quitar const donde no es válido
  fixes += await _removeInvalidConst();
  
  print('\n✅ Correcciones completadas: $fixes fixes aplicados');
}

Future<int> _fixMissingImports() async {
  print('📦 Agregando imports faltantes...');
  int count = 0;
  
  final filesToFix = [
    'lib/home_page.dart',
    'lib/community_feed_page.dart',
    'lib/post_detail_page.dart',
  ];
  
  for (var filePath in filesToFix) {
    final file = File(filePath);
    if (!await file.exists()) continue;
    
    String content = await file.readAsString();
    
    // Si usa AppColorsUnified pero no tiene el import
    if (content.contains('AppColorsUnified') && 
        !content.contains("import 'core/theme/app_colors_unified.dart'") &&
        !content.contains("import 'package:yominero/core/theme/app_colors_unified.dart'")) {
      
      // Buscar el primer import
      final importMatch = RegExp(r'import\s+.*?;').firstMatch(content);
      if (importMatch != null) {
        final insertPos = importMatch.end;
        content = content.substring(0, insertPos) +
            "\nimport 'package:yominero/core/theme/app_colors_unified.dart';" +
            content.substring(insertPos);
        await file.writeAsString(content);
        print('  ✓ $filePath');
        count++;
      }
    }
  }
  
  return count;
}

Future<int> _fixNonExistentProperties() async {
  print('\n🎨 Reemplazando propiedades inexistentes...');
  int count = 0;
  
  final libDir = Directory('lib');
  await for (var entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      final original = content;
      
      // Reemplazar propiedades inexistentes con orange (simplificado)
      content = content.replaceAll('AppColorsUnified.orangeBright', 'AppColorsUnified.orange');
      content = content.replaceAll('AppColorsUnified.orangeGlow', 'AppColorsUnified.orange');
      content = content.replaceAll('AppColorsUnified.orangeShadow', 'AppColorsUnified.fade(AppColorsUnified.orange, 0.3)');
      
      // Reemplazar DashboardAppColorsUnified con AppColorsUnified
      content = content.replaceAll('DashboardAppColorsUnified', 'AppColorsUnified');
      
      if (content != original) {
        await entity.writeAsString(content);
        print('  ✓ ${entity.path}');
        count++;
      }
    }
  }
  
  return count;
}

Future<int> _removeInvalidConst() async {
  print('\n🚫 Quitando const inválidos...');
  int count = 0;
  
  final patterns = [
    // Patrón: const Icon(..., color: AppColorsUnified.XXX)
    RegExp(r'const (Icon|Text|SizedBox|BoxDecoration|TextStyle|Row|BorderSide)\([^)]*AppColorsUnified\.[^)]+\)'),
  ];
  
  final libDir = Directory('lib');
  await for (var entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      final original = content;
      
      // Buscar y reemplazar const inválidos
      for (var pattern in patterns) {
        content = content.replaceAllMapped(pattern, (match) {
          return match.group(0)!.replaceFirst('const ', '');
        });
      }
      
      // Casos específicos adicionales
      if (content.contains('const') && content.contains('AppColorsUnified.fade')) {
        // Quitar const de cualquier expresión que contenga fade()
        content = content.replaceAllMapped(
          RegExp(r'const\s+([A-Z]\w*)\([^)]*AppColorsUnified\.fade[^)]+\)'),
          (match) => match.group(0)!.replaceFirst('const ', '')
        );
      }
      
      if (content != original) {
        await entity.writeAsString(content);
        print('  ✓ ${entity.path}');
        count++;
      }
    }
  }
  
  return count;
}
