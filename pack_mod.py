#!/usr/bin/env python3
"""
Simple X4 CAT/DAT packer for PP MAMS mod
Creates ext_01.cat and ext_01.dat from pp_mams directory
"""

import os
import hashlib
from pathlib import Path

def calculate_md5(filepath):
    """Calculate MD5 checksum of a file"""
    md5 = hashlib.md5()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            md5.update(chunk)
    return md5.hexdigest()

def pack_mod(source_dir, output_dir, exclude_patterns=None):
    """Pack mod files into CAT/DAT format"""
    if exclude_patterns is None:
        exclude_patterns = ['.backup', 'README.md', '.git']

    source_path = Path(source_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    cat_file = output_path / 'ext_01.cat'
    dat_file = output_path / 'ext_01.dat'

    cat_entries = []
    dat_offset = 0

    print(f"Packing {source_dir} into CAT/DAT...")

    # Collect all files recursively
    all_files = []
    for root, dirs, files in os.walk(source_path):
        for file in files:
            filepath = Path(root) / file
            # Skip excluded patterns
            if any(pattern in str(filepath) for pattern in exclude_patterns):
                continue
            # Get relative path from source_dir
            rel_path = filepath.relative_to(source_path)
            all_files.append((filepath, rel_path))

    # Write DAT file and build CAT entries
    with open(dat_file, 'wb') as dat:
        for filepath, rel_path in sorted(all_files):
            # Read file content
            with open(filepath, 'rb') as f:
                content = f.read()

            # Write to DAT
            dat.write(content)

            # Get file stats
            size = len(content)
            timestamp = int(filepath.stat().st_mtime)
            checksum = calculate_md5(filepath)

            # Create CAT entry (use forward slashes for paths)
            cat_path = str(rel_path).replace('\\', '/')
            cat_entry = f"{cat_path} {size} {timestamp} {checksum}"
            cat_entries.append(cat_entry)

            print(f"  Added: {cat_path} ({size} bytes)")

    # Write CAT file
    with open(cat_file, 'w', encoding='utf-8') as cat:
        for entry in cat_entries:
            cat.write(entry + '\n')

    print(f"\nCreated:")
    print(f"  {cat_file} ({len(cat_entries)} files)")
    print(f"  {dat_file} ({dat_file.stat().st_size} bytes)")

if __name__ == '__main__':
    pack_mod('pp_mams', 'pp_mams_packed', exclude_patterns=['.backup', 'README.md'])