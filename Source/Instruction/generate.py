__author__ = 'Rogiel'

import re

print(re.sub('(?!^)([A-Z]+)', r'_\1','CamelCase').lower())