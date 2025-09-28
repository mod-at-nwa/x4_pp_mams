# PP MAMS Project Structure

## Current Repository Layout

```
PRJ-369-017-x4_pp_mams/
├── CLAUDE.md                 # AI assistant guidance
├── IMPLEMENTATION_PLAN.md     # Detailed implementation plan
├── PROJECT_STRUCTURE.md      # This file
├── docs/
│   ├── project_requirements.md   # Original project requirements
│   └── research_notes.md         # X4 modding research and template notes
└── pp_mams/                     # [TO BE CREATED] Actual mod folder
    ├── content.xml
    ├── mdscripts/
    │   └── pp_mams.xml
    ├── libraries/
    │   └── pp_mams.lua
    └── README.md
```

## File Purposes

### Root Level
- **CLAUDE.md**: Instructions for AI assistants working with this codebase
- **IMPLEMENTATION_PLAN.md**: Complete technical plan for mod implementation
- **PROJECT_STRUCTURE.md**: Repository organization guide

### Documentation (docs/)
- **project_requirements.md**: Original mod concept and requirements
- **research_notes.md**: X4 modding research, template analysis, implementation approach

### Mod Package (pp_mams/)
The deliverable mod folder that will be installed in X4:
- **content.xml**: Mod registration and metadata
- **mdscripts/pp_mams.xml**: Mission Director event handling
- **libraries/pp_mams.lua**: Core pilot assignment logic
- **README.md**: End-user installation and usage guide

## Next Steps

1. Create the `pp_mams/` directory structure
2. Implement each component according to IMPLEMENTATION_PLAN.md
3. Package for distribution
4. Test in separate X4 installation

## Development Notes

- All mod files follow X4 modding conventions
- XML files use X4's Mission Director schema
- Lua scripts use X4's FFI bindings
- Directory structure matches X4 extension format