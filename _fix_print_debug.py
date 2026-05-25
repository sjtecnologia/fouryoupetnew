#!/usr/bin/env python3
"""Replace print() with debugPrint() throughout lib/ directory"""

import os
import re
import glob

BASE = os.getcwd()
LIB_PATH = os.path.join(BASE, 'lib')

# Files to target
files_to_fix = [
    'lib/helpers/send_email.dart',
    'lib/models/accommodation/accommodation_manager.dart',
    'lib/models/checkout_manager.dart',
    'lib/models/company/company_manager.dart',
    'lib/models/couponcodes/couponcode_manager.dart',
    'lib/models/loyalty/loyalty_manager.dart',
    'lib/models/order/orders_manager.dart',
]

count_total = 0

for file_path in files_to_fix:
    full_path = os.path.join(BASE, file_path)
    if not os.path.exists(full_path):
        print(f'⚠️  Arquivo não encontrado: {file_path}')
        continue
    
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace print( with debugPrint( (but not already debugPrint)
    # Pattern: word boundary + print( + not preceded by debug
    original_content = content
    content = re.sub(r'\bprint\(', 'debugPrint(', content)
    
    # Also add import if needed and not present
    if 'debugPrint(' in content and 'import \'package:flutter/foundation.dart\'' not in content:
        # Add import after other imports
        if 'import \'package:flutter' in content:
            # Find the last flutter import and add after it
            lines = content.split('\n')
            last_flutter_import_idx = -1
            for i, line in enumerate(lines):
                if 'import \'package:flutter' in line:
                    last_flutter_import_idx = i
            if last_flutter_import_idx >= 0:
                lines.insert(last_flutter_import_idx + 1, 'import \'package:flutter/foundation.dart\';')
                content = '\n'.join(lines)
    
    if content != original_content:
        count = original_content.count('print(') - content.count('print(')
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'✅ {file_path}: {count} ocorrência(s) corrigida(s)')
        count_total += count
    else:
        print(f'⊘  {file_path}: nenhuma alteração necessária')

print(f'\n✅ Fix 6 concluído: {count_total} ocorrência(s) de print() substituídas por debugPrint()')
