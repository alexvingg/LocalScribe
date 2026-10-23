#!/usr/bin/env python3
"""Check catalog coverage and formatting without translating user/model text."""
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parent.parent
literal = r'"(?:\\.|[^"\\])*"'
entry = re.compile(rf'^({literal})\s*=\s*({literal});$', re.MULTILINE)
catalogs = {}
for path in sorted((root / 'Sources/WritingCore/Resources').glob('*.lproj/Localizable.strings')):
    pairs = [(json.loads(key), json.loads(value)) for key, value in entry.findall(path.read_text())]
    assert len(pairs) == len(dict(pairs)), f'Duplicate keys: {path}'
    catalogs[path.parent.stem] = dict(pairs)

assert {'en', 'pt'} <= catalogs.keys()
base = catalogs['en']
assert all(key == value for key, value in base.items()), 'English source keys must match their English fallback'
for language, catalog in catalogs.items():
    assert catalog.keys() == base.keys(), f'Missing/extra keys: {language}'
    for key, value in catalog.items():
        assert value.strip(), f'Empty translation: {language}: {key}'
        assert re.findall(r'%(?:\d+\$)?(?:ld|@)', value) == re.findall(r'%(?:\d+\$)?(?:ld|@)', base[key]), f'Format mismatch: {language}: {key}'

used = set()
for path in (root / 'Sources').rglob('*.swift'):
    for key in re.findall(rf'L10n\.(?:text|format)\(({literal})', path.read_text()):
        used.add(json.loads(key))
assert used <= base.keys(), f'Missing strings: {used - base.keys()}'
samples = json.loads((root / 'Sources/WritingCore/Resources/LanguageSamples.json').read_text())
sample_keys = set()
for path in list((root / 'Sources').rglob('*.swift')) + list((root / 'Checks').rglob('*.swift')):
    sample_keys.update(json.loads(key) for key in re.findall(rf'LanguageSamples\.text\(({literal})', path.read_text()))
assert sample_keys <= samples.keys(), f'Missing language samples: {sample_keys - samples.keys()}'
print(f'localization-catalogs=passed languages={",".join(catalogs)} keys={len(base)} referenced={len(used)}')
print(f'language-samples=passed referenced={len(sample_keys)} source-keys=English')
