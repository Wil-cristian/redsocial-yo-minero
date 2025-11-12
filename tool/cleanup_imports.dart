import 'dart:io';

void main() async {
  print('🧹 Limpiando imports obsoletos...\n');
  
  final libDir = Directory('lib');
  final files = await _getDartFiles(libDir);
  
  int cleanedFiles = 0;
  int removedImports = 0;
  
  for (var file in files) {
    final result = await _cleanupFile(file);
    if (result > 0) {
      cleanedFiles++;
      removedImports += result;
      print('✅ ${file.path}: $result import(s) removido(s)');
    }
  }
  
  print('\n🎉 Limpieza completada!');
  print('📁 Archivos limpiados: $cleanedFiles');
  print('🗑️ Imports removidos: $removedImports');
}

Future<List<File>> _getDartFiles(Directory dir) async {
  final files = <File>[];
  await for (var entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // No procesar archivos de tema
      if (!entity.path.contains('core${Platform.pathSeparator}theme')) {
        files.add(entity);
      }
    }
  }
  return files;
}

Future<int> _cleanupFile(File file) async {
  String content = await file.readAsString();
  final originalContent = content;
  int removals = 0;
  
  // Reemplazar AppColors. antiguo con AppColorsUnified.
  final oldAppColorsUsage = RegExp(r'AppColors\.[^U]');
  if (oldAppColorsUsage.hasMatch(content)) {
    // Reemplazar referencias específicas
    content = content.replaceAll('AppColors.background', 'AppColorsUnified.background');
    content = content.replaceAll('AppColors.primary', 'AppColorsUnified.orange');
    content = content.replaceAll('AppColors.textPrimary', 'AppColorsUnified.textPrimary');
    content = content.replaceAll('AppColors.textSecondary', 'AppColorsUnified.textSecondary');
    content = content.replaceAll('AppColors.success', 'AppColorsUnified.success');
    content = content.replaceAll('AppColors.error', 'AppColorsUnified.error');
    content = content.replaceAll('AppColors.warning', 'AppColorsUnified.warning');
    removals++;
  }
  
  // Remover import 'core/theme/colors.dart' si ya no se usa
  if (content.contains("import 'core/theme/colors.dart'")) {
    // Verificar si todavía usa AppColors. (no AppColorsUnified)
    final stillUsesOldAppColors = RegExp(r'AppColors\.[^U]').hasMatch(content);
    
    if (!stillUsesOldAppColors) {
      content = content.replaceAll("import 'core/theme/colors.dart';\n", '');
      content = content.replaceAll("import 'core/theme/colors.dart';", '');
      removals++;
    }
  }
  
  // Remover import de dashboard_colors.dart si no se usa
  if (content.contains("import 'core/theme/dashboard_colors.dart'") ||
      content.contains('import "core/theme/dashboard_colors.dart"')) {
    if (!content.contains('DashboardColors.')) {
      content = content.replaceAll("import 'core/theme/dashboard_colors.dart';\n", '');
      content = content.replaceAll("import 'core/theme/dashboard_colors.dart';", '');
      content = content.replaceAll('import "core/theme/dashboard_colors.dart";\n', '');
      content = content.replaceAll('import "core/theme/dashboard_colors.dart";', '');
      removals++;
    }
  }
  
  // Remover líneas vacías múltiples que quedan después de remover imports
  content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  
  if (content != originalContent) {
    await file.writeAsString(content);
  }
  
  return removals;
}
