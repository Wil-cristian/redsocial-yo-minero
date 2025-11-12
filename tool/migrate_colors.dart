import 'dart:io';

void main() async {
  print('🎨 Iniciando migración masiva de colores...\n');
  
  final libDir = Directory('lib');
  final files = await _getDartFiles(libDir);
  
  int totalFiles = 0;
  int totalReplacements = 0;
  
  for (var file in files) {
    final result = await _migrateFile(file);
    if (result > 0) {
      totalFiles++;
      totalReplacements += result;
      print('✅ ${file.path}: $result reemplazos');
    }
  }
  
  print('\n🎉 Migración completada!');
  print('📁 Archivos modificados: $totalFiles');
  print('🔄 Total reemplazos: $totalReplacements');
}

Future<List<File>> _getDartFiles(Directory dir) async {
  final files = <File>[];
  await for (var entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Excluir archivos ya migrados y core/theme
      if (!entity.path.contains('core${Platform.pathSeparator}theme') &&
          !entity.path.contains('community_feed_page.dart') &&
          !entity.path.contains('mining_production_dashboard.dart') &&
          !entity.path.contains('post_detail_page.dart') &&
          !entity.path.contains('profile_page.dart') &&
          !entity.path.contains('settings_page.dart') &&
          !entity.path.contains('group_chat_page.dart')) {
        files.add(entity);
      }
    }
  }
  return files;
}

Future<int> _migrateFile(File file) async {
  String content = await file.readAsString();
  final originalContent = content;
  int replacements = 0;
  
  // Agregar import si no existe
  if (!content.contains("import 'package:yominero/core/theme/app_colors_unified.dart'") &&
      !content.contains('import "package:yominero/core/theme/app_colors_unified.dart"')) {
    // Buscar el último import
    final importRegex = RegExp(r'import [' + "'" + r'"].*[' + "'" + r'"];');
    final matches = importRegex.allMatches(content);
    if (matches.isNotEmpty) {
      final lastImport = matches.last;
      final insertPosition = lastImport.end;
      content = content.substring(0, insertPosition) +
          "\nimport 'package:yominero/core/theme/app_colors_unified.dart';" +
          content.substring(insertPosition);
      replacements++;
    }
  }
  
  // Reemplazos simples de Colors.X
  final simpleReplacements = {
    'Colors.white': 'AppColorsUnified.pureWhite',
    'Colors.black': 'AppColorsUnified.charcoal',
    'Colors.black87': 'AppColorsUnified.textPrimary',
    'Colors.grey': 'AppColorsUnified.textSecondary',
    'Colors.orange': 'AppColorsUnified.orange',
    'Colors.green': 'AppColorsUnified.success',
    'Colors.red': 'AppColorsUnified.error',
  };
  
  for (var entry in simpleReplacements.entries) {
    final count = entry.key.allMatches(content).length;
    if (count > 0) {
      content = content.replaceAll(entry.key, entry.value);
      replacements += count;
    }
  }
  
  // Reemplazar Colors.grey[X]
  content = _replaceGreyShades(content, ref: (c) => replacements += c);
  
  // Reemplazar .withValues(alpha: X) con fade()
  content = _replaceWithValues(content, ref: (c) => replacements += c);
  
  // Reemplazar Color(0xFFFFFFFF) y similares
  content = _replaceColorHex(content, ref: (c) => replacements += c);
  
  // Reemplazar DashboardColors.primary
  if (content.contains('DashboardColors.primary')) {
    content = content.replaceAll('DashboardColors.primary', 'AppColorsUnified.orange');
    replacements += 'DashboardColors.primary'.allMatches(originalContent).length;
  }
  
  // Remover import de dashboard_colors si existe y no se usa más
  if (content.contains("import 'core/theme/dashboard_colors.dart'") ||
      content.contains('import "core/theme/dashboard_colors.dart"')) {
    if (!content.contains('DashboardColors.')) {
      content = content.replaceAll(RegExp(r'import [' + "'" + r'"]core/theme/dashboard_colors\.dart[' + "'" + r'"];?\n?'), '');
      replacements++;
    }
  }
  
  if (content != originalContent) {
    await file.writeAsString(content);
  }
  
  return replacements;
}

String _replaceGreyShades(String content, {required void Function(int) ref}) {
  int count = 0;
  
  // Colors.grey[50] - muy claro
  if (content.contains('Colors.grey[50]')) {
    content = content.replaceAll('Colors.grey[50]', 'AppColorsUnified.background');
    count += 'Colors.grey[50]'.allMatches(content).length;
  }
  
  // Colors.grey[100] - claro
  if (content.contains('Colors.grey[100]')) {
    content = content.replaceAll('Colors.grey[100]', 'AppColorsUnified.background');
    count += 'Colors.grey[100]'.allMatches(content).length;
  }
  
  // Colors.grey[200] - border claro
  if (content.contains('Colors.grey[200]')) {
    content = content.replaceAll('Colors.grey[200]!', 'AppColorsUnified.background');
    content = content.replaceAll('Colors.grey[200]', 'AppColorsUnified.background');
    count += 'Colors.grey[200]'.allMatches(content).length;
  }
  
  // Colors.grey[300] - border medio
  if (content.contains('Colors.grey[300]')) {
    content = content.replaceAll('Colors.grey[300]!', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)');
    content = content.replaceAll('Colors.grey[300]', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)');
    count += 'Colors.grey[300]'.allMatches(content).length;
  }
  
  // Colors.grey[400] - texto claro
  if (content.contains('Colors.grey[400]')) {
    content = content.replaceAll('Colors.grey[400]!', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)');
    content = content.replaceAll('Colors.grey[400]', 'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.2)');
    count += 'Colors.grey[400]'.allMatches(content).length;
  }
  
  // Colors.grey[500] - texto secundario
  if (content.contains('Colors.grey[500]')) {
    content = content.replaceAll('Colors.grey[500]!', 'AppColorsUnified.textSecondary');
    content = content.replaceAll('Colors.grey[500]', 'AppColorsUnified.textSecondary');
    count += 'Colors.grey[500]'.allMatches(content).length;
  }
  
  // Colors.grey[600] - texto medio
  if (content.contains('Colors.grey[600]')) {
    content = content.replaceAll('Colors.grey[600]!', 'AppColorsUnified.textSecondary');
    content = content.replaceAll('Colors.grey[600]', 'AppColorsUnified.textSecondary');
    count += 'Colors.grey[600]'.allMatches(content).length;
  }
  
  // Colors.grey[700] - texto oscuro
  if (content.contains('Colors.grey[700]')) {
    content = content.replaceAll('Colors.grey[700]!', 'AppColorsUnified.textPrimary');
    content = content.replaceAll('Colors.grey[700]', 'AppColorsUnified.textPrimary');
    count += 'Colors.grey[700]'.allMatches(content).length;
  }
  
  // Colors.grey[800] - muy oscuro
  if (content.contains('Colors.grey[800]')) {
    content = content.replaceAll('Colors.grey[800]!', 'AppColorsUnified.charcoal');
    content = content.replaceAll('Colors.grey[800]', 'AppColorsUnified.charcoal');
    count += 'Colors.grey[800]'.allMatches(content).length;
  }
  
  // Colors.grey[900] - casi negro
  if (content.contains('Colors.grey[900]')) {
    content = content.replaceAll('Colors.grey[900]!', 'AppColorsUnified.charcoal');
    content = content.replaceAll('Colors.grey[900]', 'AppColorsUnified.charcoal');
    count += 'Colors.grey[900]'.allMatches(content).length;
  }
  
  ref(count);
  return content;
}

String _replaceWithValues(String content, {required void Function(int) ref}) {
  int count = 0;
  
  // Patrón: Colors.white.withValues(alpha: 0.X)
  final regex = RegExp(r'(Colors\.white|AppColorsUnified\.pureWhite)\.withValues\(alpha:\s*([\d.]+)\)');
  final matches = regex.allMatches(content);
  
  for (var match in matches) {
    final alpha = match.group(2)!;
    final replacement = 'AppColorsUnified.fade(AppColorsUnified.pureWhite, $alpha)';
    content = content.replaceFirst(match.group(0)!, replacement);
    count++;
  }
  
  // Patrón: Colors.black.withValues(alpha: 0.X)
  final blackRegex = RegExp(r'(Colors\.black|AppColorsUnified\.charcoal)\.withValues\(alpha:\s*([\d.]+)\)');
  final blackMatches = blackRegex.allMatches(content);
  
  for (var match in blackMatches) {
    final alpha = match.group(2)!;
    final replacement = 'AppColorsUnified.fade(AppColorsUnified.charcoal, $alpha)';
    content = content.replaceFirst(match.group(0)!, replacement);
    count++;
  }
  
  // Patrón: DashboardColors.primary.withValues(alpha: 0.X)
  final primaryRegex = RegExp(r'DashboardColors\.primary\.withValues\(alpha:\s*([\d.]+)\)');
  final primaryMatches = primaryRegex.allMatches(content);
  
  for (var match in primaryMatches) {
    final alpha = match.group(1)!;
    final replacement = 'AppColorsUnified.fade(AppColorsUnified.orange, $alpha)';
    content = content.replaceFirst(match.group(0)!, replacement);
    count++;
  }
  
  // Patrón genérico: X.withValues(alpha: Y)
  final genericRegex = RegExp(r'(AppColorsUnified\.\w+)\.withValues\(alpha:\s*([\d.]+)\)');
  final genericMatches = genericRegex.allMatches(content);
  
  for (var match in genericMatches) {
    final color = match.group(1)!;
    final alpha = match.group(2)!;
    final replacement = 'AppColorsUnified.fade($color, $alpha)';
    content = content.replaceFirst(match.group(0)!, replacement);
    count++;
  }
  
  ref(count);
  return content;
}

String _replaceColorHex(String content, {required void Function(int) ref}) {
  int count = 0;
  
  // Color(0xFFFFFFFF) -> pureWhite
  if (content.contains('Color(0xFFFFFFFF)')) {
    content = content.replaceAll('Color(0xFFFFFFFF)', 'AppColorsUnified.pureWhite');
    count += 'Color(0xFFFFFFFF)'.allMatches(content).length;
  }
  
  // Color(0xFF000000) -> charcoal
  if (content.contains('Color(0xFF000000)')) {
    content = content.replaceAll('Color(0xFF000000)', 'AppColorsUnified.charcoal');
    count += 'Color(0xFF000000)'.allMatches(content).length;
  }
  
  // Color(0xFFFF8C00) -> orange
  if (content.contains('Color(0xFFFF8C00)')) {
    content = content.replaceAll('Color(0xFFFF8C00)', 'AppColorsUnified.orange');
    count += 'Color(0xFFFF8C00)'.allMatches(content).length;
  }
  
  // Color(0xFFD4AF37) -> gold
  if (content.contains('Color(0xFFD4AF37)')) {
    content = content.replaceAll('Color(0xFFD4AF37)', 'AppColorsUnified.gold');
    count += 'Color(0xFFD4AF37)'.allMatches(content).length;
  }
  
  // Color(0xFFFAF8F3) -> background
  if (content.contains('Color(0xFFFAF8F3)')) {
    content = content.replaceAll('Color(0xFFFAF8F3)', 'AppColorsUnified.background');
    count += 'Color(0xFFFAF8F3)'.allMatches(content).length;
  }
  
  ref(count);
  return content;
}
