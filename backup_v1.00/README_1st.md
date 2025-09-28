# PP MAMS Version 1.00 Backup

**Date Backed Up**: 2025-09-28
**Original Location**: `/home/steam/.local/share/Steam/steamapps/common/X4 Foundations/extensions/pp_mams`

## Why This Was Backed Up

This folder contains the **original version 1.00** of the PP MAMS mod that was installed in the steam user's X4 extensions directory. This version was preventing the updated version 1.02 from loading properly because X4 was loading this copy instead of the development version.

## Contents

This backup contains the complete mod structure with:
- **content.xml**: Version 100 (displays as 1.00 in-game)
- **libraries/**: Contains pp_mams.lua file that was causing loading issues
- **mdscripts/**: Contains the original MD script
- **README.md**: Original documentation

## Issues with This Version

1. **Lua Library Declaration**: Declared but not properly used, causing silent loading failures
2. **Dependency Declaration**: May have caused version conflicts
3. **Version Conflicts**: Same mod ID caused conflict with development version

## Resolution

The steam user's installation was replaced with the simplified version 1.02 that:
- Removes unused Lua library declarations
- Removes dependency requirements
- Uses MD-only approach for initial testing
- Has proper version numbering (1.02)

## Recovery

If needed, this backup can be restored by copying the `pp_mams` folder back to:
```
/home/steam/.local/share/Steam/steamapps/common/X4 Foundations/extensions/
```

However, it's recommended to use the updated version 1.02+ instead.