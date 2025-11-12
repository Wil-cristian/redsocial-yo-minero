import 'dart:io';

/// Script para migrar theme.dart a AppColorsUnified con mapeo inteligente
void main() async {
  print('🎨 Migrando theme.dart a AppColorsUnified...\n');

  final file = File('lib/core/theme/theme.dart');
  if (!file.existsSync()) {
    print('❌ Archivo theme.dart no encontrado');
    return;
  }

  String content = await file.readAsString();
  final originalContent = content;

  // Mapeo de colores DashboardColors -> AppColorsUnified
  final Map<String, String> colorMap = {
    // Primary colors
    'DashboardColors.primary': 'AppColorsUnified.orange',
    'DashboardColors.primaryDark': 'AppColorsUnified.darken(AppColorsUnified.orange, 0.2)',
    'DashboardColors.primaryLight': 'AppColorsUnified.lighten(AppColorsUnified.orange, 0.2)',
    
    // Accent colors
    'DashboardColors.accent': 'AppColorsUnified.gold',
    'DashboardColors.accentLight': 'AppColorsUnified.lighten(AppColorsUnified.gold, 0.3)',
    
    // Charcoal/Dark colors
    'DashboardColors.charcoal': 'AppColorsUnified.charcoal',
    
    // White
    'DashboardColors.white': 'AppColorsUnified.pureWhite',
    
    // Gray scale (maintain gray for UI elements)
    'DashboardColors.gray50': 'AppColorsUnified.background', // or keep gray for inputs
    'DashboardColors.gray100': 'AppColorsUnified.lighten(AppColorsUnified.background, 0.05)',
    'DashboardColors.gray200': 'AppColorsUnified.fade(AppColorsUnified.charcoal, 0.1)',
    'DashboardColors.gray300': 'AppColorsUnified.fade(AppColorsUnified.charcoal, 0.2)',
    'DashboardColors.gray700': 'AppColorsUnified.textSecondary',
    
    // Error (keep red for errors)
    'DashboardColors.error': 'AppColorsUnified.error',
    
    // Flutter Colors.white
    'Colors.white': 'AppColorsUnified.pureWhite',
    'Colors.transparent': 'Colors.transparent', // Keep transparent
  };

  int replacements = 0;

  // Realizar reemplazos
  colorMap.forEach((oldColor, newColor) {
    final count = oldColor.allMatches(content).length;
    if (count > 0) {
      content = content.replaceAll(oldColor, newColor);
      replacements += count;
      print('  ✓ $oldColor → $newColor ($count usos)');
    }
  });

  // Actualizar imports
  if (content.contains("import 'dashboard_colors.dart';")) {
    content = content.replaceAll(
      "import 'dashboard_colors.dart';",
      "import 'app_colors_unified.dart';",
    );
    print('\n  ✓ Import actualizado: dashboard_colors.dart → app_colors_unified.dart');
  }

  // Fix withValues(alpha:) calls - remove them since AppColorsUnified.fade handles opacity
  final withValuesRegex = RegExp(r'\.withValues\(alpha:\s*[\d.]+\)');
  final withValuesMatches = withValuesRegex.allMatches(content).toList();
  if (withValuesMatches.isNotEmpty) {
    print('\n  ⚠️  Encontradas ${withValuesMatches.length} llamadas .withValues(alpha:)');
    print('      Estas necesitan ser convertidas manualmente a AppColorsUnified.fade()');
  }

  if (content != originalContent) {
    await file.writeAsString(content);
    print('\n═══════════════════════════════════════════════════════');
    print('✅ theme.dart migrado exitosamente!');
    print('📊 Total de reemplazos: $replacements');
    print('═══════════════════════════════════════════════════════\n');
    
    print('⚠️  SIGUIENTE PASO MANUAL:');
    print('   Busca ".withValues(alpha:" en el archivo y convierte a:');
    print('   AppColorsUnified.fade(color, opacity)');
    print('');
  } else {
    print('\n⚠️  No se realizaron cambios');
  }
}
