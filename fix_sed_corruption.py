#!/usr/bin/env python3
"""
Script para reparar archivos corruptos por sed.
Restaura las referencias de colores eliminadas incorrectamente.
"""

import re
import sys
from pathlib import Path

# Archivos afectados
AFFECTED_FILES = [
    "lib/change_password_page.dart",
    "lib/core/theme/rich_decorations.dart",
    "lib/core/theme/theme.dart",
    "lib/edit_profile_page.dart",
    "lib/group_chat_page.dart",
    "lib/group_detail_page.dart",
    "lib/groups_page.dart",
    "lib/home_page.dart",
    "lib/login_page.dart",
    "lib/main_app.dart",
    "lib/manage_products_page.dart",
    "lib/manage_services_page.dart",
    "lib/messages_page.dart",
    "lib/notifications_page.dart",
    "lib/post_detail_page.dart",
    "lib/product_detail_page.dart",
    "lib/products_page.dart",
    "lib/profile_page.dart",
    "lib/register_page.dart",
    "lib/requests_page.dart",
    "lib/service_detail_page.dart",
    "lib/services_page.dart",
    "lib/shared/widgets/optimized_post_content.dart",
    "lib/suggestions_page.dart",
    "lib/user_type_selection_page.dart",
]

def fix_file(filepath):
    """Repara un archivo corrupto."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Patrón CRÍTICO: Theme.of(context) AppColors.textTheme → Theme.of(context).textTheme
        # Este patrón debe ejecutarse PRIMERO
        content = re.sub(
            r'Theme\.of\(context\)\s+AppColors\.textTheme',
            r'Theme.of(context).textTheme',
            content
        )
        
        # También para DashboardColors
        content = re.sub(
            r'Theme\.of\(context\)\s+DashboardColors\.textTheme',
            r'Theme.of(context).textTheme',
            content
        )
        
        # Patrón 1: BorderSide(.colorName) → BorderSide(color: DashboardColors.colorName)
        content = re.sub(
            r'BorderSide\(\.(\w+)',
            r'BorderSide(color: DashboardColors.\1',
            content
        )
        
        # Patrón 2: TextStyle(.colorName) → TextStyle(color: DashboardColors.colorName)
        content = re.sub(
            r'TextStyle\(\.(\w+)',
            r'TextStyle(color: DashboardColors.\1',
            content
        )
        
        # Patrón 3: .colorName aislado → DashboardColors.colorName
        # (solo cuando está precedido por espacio, paréntesis o coma)
        content = re.sub(
            r'([\s\(,])\.(\w+)(\s*[,\)])',
            r'\1DashboardColors.\2\3',
            content
        )
        
        # Patrón 4: AppColors sin prefijo correcto
        content = re.sub(
            r'([\s\(,])\.(\w+)(\s+)',
            r'\1AppColors.\2\3',
            content
        )
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Fixed: {filepath}")
            return True
        else:
            print(f"⏭️  No changes: {filepath}")
            return False
            
    except Exception as e:
        print(f"❌ Error fixing {filepath}: {e}")
        return False

def main():
    """Repara todos los archivos afectados."""
    print("🔧 Iniciando reparación de archivos corruptos (v2)...\n")
    
    fixed = 0
    for filepath in AFFECTED_FILES:
        if Path(filepath).exists():
            if fix_file(filepath):
                fixed += 1
        else:
            print(f"⚠️  File not found: {filepath}")
    
    print(f"\n✨ Reparación completada: {fixed}/{len(AFFECTED_FILES)} archivos modificados")

if __name__ == "__main__":
    main()
