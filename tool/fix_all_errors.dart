import 'dart:io';

void main() async {
  print('🔧 Corrigiendo TODOS los errores de compilación...\n');
  
  final libDir = Directory('lib');
  final files = await _getDartFiles(libDir);
  
  int fixedFiles = 0;
  int totalFixes = 0;
  
  for (var file in files) {
    final fixes = await _fixFile(file);
    if (fixes > 0) {
      fixedFiles++;
      totalFixes += fixes;
      print('✅ ${file.path}: $fixes correcciones');
    }
  }
  
  print('\n🎉 Corrección completada!');
  print('📁 Archivos corregidos: $fixedFiles');
  print('🔧 Total correcciones: $totalFixes');
}

Future<List<File>> _getDartFiles(Directory dir) async {
  final files = <File>[];
  await for (var entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && 
        !entity.path.contains('core${Platform.pathSeparator}theme')) {
      files.add(entity);
    }
  }
  return files;
}

Future<int> _fixFile(File file) async {
  String content = await file.readAsString();
  final originalContent = content;
  int fixes = 0;
  
  // 1. Quitar const de Icons con colores no constantes
  final constIconPattern = RegExp(r'const Icon\([^)]+AppColorsUnified\.[^)]+\)');
  if (constIconPattern.hasMatch(content)) {
    content = content.replaceAllMapped(constIconPattern, (match) {
      fixes++;
      return match.group(0)!.replaceFirst('const ', '');
    });
  }
  
  // 2. Quitar const de Text con colores no constantes
  final constTextPattern = RegExp(r'const Text\([^}]+AppColorsUnified\.[^}]+\}[^)]*\)');
  if (constTextPattern.hasMatch(content)) {
    content = content.replaceAllMapped(constTextPattern, (match) {
      fixes++;
      return match.group(0)!.replaceFirst('const ', '');
    });
  }
  
  // 3. Quitar const de TextStyle con colores no constantes
  final constTextStylePattern = RegExp(r'const TextStyle\([^}]+AppColorsUnified\.[^}]+\)');
  if (constTextStylePattern.hasMatch(content)) {
    content = content.replaceAllMapped(constTextStylePattern, (match) {
      fixes++;
      return match.group(0)!.replaceFirst('const ', '');
    });
  }
  
  // 4. Quitar const de BoxDecoration con colores no constantes
  final constBoxPattern = RegExp(r'const BoxDecoration\([^}]+AppColorsUnified\.[^}]+\)');
  if (constBoxPattern.hasMatch(content)) {
    content = content.replaceAllMapped(constBoxPattern, (match) {
      fixes++;
      return match.group(0)!.replaceFirst('const ', '');
    });
  }
  
  // 5. Quitar const de BorderSide con colores no constantes
  final constBorderPattern = RegExp(r'const BorderSide\([^)]+AppColorsUnified\.[^)]+\)');
  if (constBorderPattern.hasMatch(content)) {
    content = content.replaceAllMapped(constBorderPattern, (match) {
      fixes++;
      return match.group(0)!.replaceFirst('const ', '');
    });
  }
  
  // 6. Quitar const de SizedBox con CircularProgressIndicator que tiene colores
  final constSizedBoxPattern = RegExp(r'const SizedBox\([^{]+\{[^}]*AppColorsUnified[^}]*\}[^)]*\)', multiLine: true);
  if (constSizedBoxPattern.hasMatch(content)) {
    content = content.replaceAllMapped(constSizedBoxPattern, (match) {
      fixes++;
      return match.group(0)!.replaceFirst('const ', '');
    });
  }
  
  // 7. Reemplazar operador [] en Color con lighten/darken
  // textSecondary[600] -> textSecondary (es el mismo)
  content = content.replaceAll('AppColorsUnified.textSecondary[700]', 'AppColorsUnified.charcoal');
  content = content.replaceAll('AppColorsUnified.textSecondary[600]', 'AppColorsUnified.textSecondary');
  content = content.replaceAll('AppColorsUnified.textSecondary[500]', 'AppColorsUnified.textSecondary');
  content = content.replaceAll('AppColorsUnified.textSecondary[400]', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)');
  content = content.replaceAll('AppColorsUnified.textSecondary[300]', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)');
  content = content.replaceAll('AppColorsUnified.textSecondary[200]', 'AppColorsUnified.background');
  content = content.replaceAll('AppColorsUnified.textSecondary[100]', 'AppColorsUnified.background');
  content = content.replaceAll('AppColorsUnified.textSecondary[50]', 'AppColorsUnified.background');
  
  // 8. Reemplazar .shadeX con equivalentes
  content = content.replaceAll('AppColorsUnified.textSecondary.shade700', 'AppColorsUnified.charcoal');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade600', 'AppColorsUnified.textSecondary');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade500', 'AppColorsUnified.textSecondary');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade400', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade300', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade200', 'AppColorsUnified.background');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade100', 'AppColorsUnified.background');
  content = content.replaceAll('AppColorsUnified.textSecondary.shade50', 'AppColorsUnified.background');
  
  // 9. Reemplazar propiedades inexistentes
  content = content.replaceAll('AppColorsUnified.charcoal87', 'AppColorsUnified.textPrimary');
  content = content.replaceAll('AppColorsUnified.charcoal26', 'AppColorsUnified.fade(AppColorsUnified.charcoal, 0.26)');
  content = content.replaceAll('AppColorsUnified.pureWhite70', 'AppColorsUnified.fade(AppColorsUnified.pureWhite, 0.7)');
  content = content.replaceAll('AppColorsUnified.orangeContainer', 'AppColorsUnified.fade(AppColorsUnified.orange, 0.1)');
  content = content.replaceAll('AppColorsUnified.backgroundAlt', 'AppColorsUnified.background');
  
  // 10. Reemplazar DashboardAppColorsUnified (typo)
  content = content.replaceAll('DashboardAppColorsUnified.orange', 'AppColorsUnified.orange');
  content = content.replaceAll('DashboardAppColorsUnified.orangeBright', 'AppColorsUnified.lighten(AppColorsUnified.orange, 0.1)');
  
  // 11. Reemplazar DashboardColors restantes
  content = content.replaceAll('DashboardColors.cardOrange', 'AppColorsUnified.orange');
  content = content.replaceAll('DashboardColors.primary', 'AppColorsUnified.orange');
  
  // 12. Corregir el error de const gold en floating_radial_button
  content = content.replaceAll('const AppColorsUnified.gold', 'AppColorsUnified.gold');
  
  if (content != originalContent) {
    await file.writeAsString(content);
    fixes = content.split('\n').length - originalContent.split('\n').length + 1;
  }
  
  return fixes;
}
