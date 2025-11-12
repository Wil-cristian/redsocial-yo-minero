import 'dart:io';

void main() async {
  print('🔧 Corrigiendo errores restantes...\n');

  // 1. Remover imports no usados
  await _removeUnusedImports();

  // 2. Corregir operador [] en dashboard_grid_item.dart
  await _fixDashboardGridItem();

  // 3. Remover ! innecesarios
  await _removeUnnecessaryNullChecks();

  // 4. Corregir floating_radial_button.dart const con fade
  await _fixFloatingRadialButtonConst();

  print('\n✅ Correcciones completadas!');
}

Future<void> _removeUnusedImports() async {
  print('📦 Removiendo imports no usados...');
  
  final filesToClean = [
    'lib/pages/messaging/conversations_page.dart',
    'lib/pages/messaging/search_users_page.dart',
    'lib/edit_profile_page.dart',
    'lib/messages_page.dart',
    'lib/core/routing/app_router.dart',
    'lib/features/notifications/data/supabase_notifications_repository.dart',
    'lib/features/products/data/supabase_product_repository.dart',
    'lib/features/products/data/in_memory_product_repository.dart',
    'lib/features/metrics/data/supabase_metrics_repository.dart',
    'lib/features/messaging/data/supabase_messaging_repository.dart',
    'lib/features/services/domain/service_repository.dart',
    'lib/shared/models/user.dart',
    'lib/core/supabase/supabase_service.dart',
    'lib/core/supabase/supabase_config.dart',
    'lib/core/products/product_mapper.dart',
    'lib/core/matching/match_engine.dart',
    'lib/core/groups/group_repository.dart',
    'lib/core/favorites/favorite_models.dart',
    'lib/core/auth/user_storage_service.dart',
    'lib/core/auth/supabase_auth_service.dart',
    'lib/core/achievements/achievement_models.dart',
  ];

  int count = 0;
  for (final path in filesToClean) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    String content = await file.readAsString();
    String original = content;
    
    // Remover imports obsoletos - línea completa
    final lines = content.split('\n');
    final newLines = <String>[];
    
    for (final line in lines) {
      if (line.contains("import") && 
          (line.contains("colors.dart") || 
           line.contains("app_colors_unified.dart")) &&
          !line.contains("package:yominero/core/theme/app_colors_unified.dart")) {
        // Skip esta línea
        continue;
      }
      newLines.add(line);
    }
    
    content = newLines.join('\n');
    
    if (content != original) {
      await file.writeAsString(content);
      print('  ✓ $path');
      count++;
    }
  }
  
  print('  Archivos limpiados: $count');
}

Future<void> _fixDashboardGridItem() async {
  print('\n🔧 Corrigiendo dashboard_grid_item.dart...');
  
  final file = File('lib/shared/widgets/dashboard_grid_item.dart');
  if (!file.existsSync()) {
    print('  ⚠️  Archivo no encontrado');
    return;
  }
  
  String content = await file.readAsString();
  
  // Reemplazar textSecondary[800] con darken
  content = content.replaceAll(
    'AppColorsUnified.textSecondary[800]',
    'AppColorsUnified.darken(AppColorsUnified.textSecondary, 0.2)'
  );
  
  await file.writeAsString(content);
  print('  ✓ Corregido operador []');
}

Future<void> _removeUnnecessaryNullChecks() async {
  print('\n🚫 Removiendo ! innecesarios...');
  
  final filesToFix = [
    'lib/chat_detail_page.dart',
    'lib/employee_chat_page.dart',
    'lib/login_page.dart',
  ];

  int count = 0;
  for (final path in filesToFix) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    String content = await file.readAsString();
    String original = content;
    
    // Remover ! después de propiedades de AppColorsUnified
    content = content.replaceAll('AppColorsUnified.background!', 'AppColorsUnified.background');
    content = content.replaceAll('AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)!', 
                                   'AppColorsUnified.lighten(AppColorsUnified.textSecondary, 0.4)');
    
    if (content != original) {
      await file.writeAsString(content);
      print('  ✓ $path');
      count++;
    }
  }
  
  print('  Archivos corregidos: $count');
}

Future<void> _fixFloatingRadialButtonConst() async {
  print('\n🎨 Corrigiendo const en floating_radial_button.dart...');
  
  final file = File('lib/shared/widgets/floating_radial_button.dart');
  if (!file.existsSync()) {
    print('  ⚠️  Archivo no encontrado');
    return;
  }
  
  String content = await file.readAsString();
  
  // Buscar y remover const antes de fade()
  // Patrón: const Positioned(...color: AppColorsUnified.fade...)
  content = content.replaceAllMapped(
    RegExp(r'const\s+(Positioned\([^)]*?color:\s*AppColorsUnified\.fade[^)]*?\)[^;]*?;)', multiLine: true),
    (match) => match.group(1)!
  );
  
  await file.writeAsString(content);
  print('  ✓ Removido const con fade()');
}
