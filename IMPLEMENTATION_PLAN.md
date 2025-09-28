# X4 PP MAMS Mod Implementation Plan

## Project: Pilot Personnel Merit Assignment Management System (PP MAMS)

### Objective
Create an X4 mod that automatically assigns optimal pilots to newly purchased ships based on merit and specific conditions, replacing default pilots with better candidates from the personnel pool.

## Mod Directory Structure

```
pp_mams/
├── content.xml              # Mod registration and metadata
├── mdscripts/
│   └── pp_mams.xml         # Mission Director event handling
├── libraries/
│   └── pp_mams.lua         # Pilot assignment logic
├── t/                      # Localization files (future)
│   └── 0001-l044.xml       # English text definitions
└── ui/                     # UI modifications (future)
    └── addons/
        └── pp_mams_config.lua  # Settings menu integration
```

## Implementation Components

### 1. content.xml - Mod Registration
- **Purpose**: Register mod with X4 game engine
- **Contents**:
  - Mod ID: `pp_mams`
  - Name: "Pilot Personnel Merit Assignment Management System"
  - Version: 1.0.0
  - Dependencies: None (standalone)
  - Save compatibility: false (doesn't break saves)

### 2. Mission Director Script (mdscripts/pp_mams.xml)
- **Event Handlers**:
  - `event_object_built`: Triggers when player purchases new ship
  - `event_object_crew_changed`: Triggers when ship loses pilot
- **Parameters**:
  - `notify`: Boolean for notification display
  - `logbook`: Boolean for logbook entries
- **Logic Flow**:
  1. Detect ship type (battle vs non-combat)
  2. Call appropriate Lua function for pilot assignment
  3. Handle notifications and logging

### 3. Lua Logic Script (libraries/pp_mams.lua)
- **Core Functions**:
  - `assign_best_pilot()`: For battle ships
  - `assign_best_crew_as_pilot()`: For non-combat ships
  - `getPilotingSkill()`: Helper for skill evaluation
- **Assignment Rules**:
  - Battle ships: Get highest skilled pilot, can scalp from non-combat
  - Non-combat: Promote best available crew from PHQ pool
  - Fallback: Keep default if no better candidate

### 4. Localization Support (t/0001-l044.xml)
- Text strings for notifications
- Logbook entry templates
- Settings descriptions

## Technical Implementation Details

### Ship Classification
- **Battle Ships**: `purpose == 'fight'`
  - Fighters, destroyers, carriers
  - Priority for best pilots
- **Non-Combat Ships**: All others
  - Traders, miners, builders
  - Use available crew pool

### Personnel Pool Management
- **Source**: Player Headquarters (PHQ) service crew
- **Evaluation**: Piloting skill comparison
- **Movement**: FFI calls to X4 engine
  - `RemovePilot()`: Remove from current ship
  - `AssignPilot()`: Assign to new ship
  - `MoveCrewToContainer()`: Transfer between locations

### Error Handling
- Check for PHQ existence before crew operations
- Validate pilot availability before transfer
- Graceful fallback to default pilot

## Configuration Options

### Current Settings (XML Parameters)
1. **Notification on assignment**: Show/hide in-game notifications
2. **Assignment in Logbook**: Enable/disable logbook entries

### Future Enhancement Path
- Integration with "SirNukes Mod Support APIs"
- In-game configuration menu
- Per-ship-class assignment rules
- Skill threshold settings

## Testing Strategy

### Test Scenarios
1. **New Ship Purchase**
   - Buy fighter → Should get best pilot
   - Buy trader → Should get best crew member

2. **Pilot Loss Events**
   - Pilot dies in combat
   - Manual pilot removal

3. **Edge Cases**
   - No PHQ available
   - No better pilots available
   - Multiple ships purchased simultaneously

### Debug Tools
- X4 debug flags: `-debug scripts -logfile debuglog.txt`
- Template webserver for data inspection
- Console logging in Lua scripts

## Development Phases

### Phase 1: Core Implementation ✓
- Basic mod structure
- Event handling
- Assignment logic

### Phase 2: Polish & Configuration
- Notifications system
- Logbook integration
- Error handling

### Phase 3: Enhanced Features (Future)
- UI configuration menu
- Advanced assignment rules
- Crew hiring integration

## File Deliverables

1. **pp_mams/** - Complete mod folder
2. **README.md** - Installation and usage guide
3. **CLAUDE.md** - Development documentation (already created)
4. **CHANGELOG.md** - Version history (future)

## Installation Process
1. Copy `pp_mams` folder to X4 extensions directory
2. Enable in game's Extension menu
3. Configure settings in XML (or future UI)
4. Load save or start new game

## Success Criteria
- [x] Automatic pilot assignment on ship purchase
- [x] Merit-based selection logic
- [x] Battle vs non-combat differentiation
- [x] Configurable notifications
- [x] Clean error handling
- [ ] User testing and feedback integration