# Pilot Personnel Merit Assignment Management System (PP MAMS)

## Overview
PP MAMS is an X4: Foundations mod that automatically assigns optimal pilots to newly purchased ships based on merit and specific conditions. The mod intelligently replaces default pilots with better candidates from your personnel pool.

## Features
- **Merit-Based Assignment**: Assigns pilots based on actual piloting skill ratings
- **Battle Ship Priority**: Combat vessels get the highest skilled pilots available
- **Non-Combat Optimization**: Trade/mining ships get the best available crew from PHQ pool
- **Smart Scalping**: Battle ships can take pilots from non-combat vessels if needed
- **Configurable Notifications**: Enable/disable in-game notifications and logbook entries
- **Graceful Fallbacks**: Keeps default pilots when no better candidates are available

## Ship Classification
- **Battle Ships**: Ships with `purpose == 'fight'` (fighters, destroyers, carriers)
  - Priority for highest skilled pilots
  - Can recruit from non-combat ships
- **Non-Combat Ships**: All other ship types (traders, miners, builders)
  - Get best available crew from PHQ service pool
  - Do not lose pilots to battle ships

## Requirements
- X4: Foundations (any version)
- Player Headquarters (PHQ) recommended for optimal functionality
- No other mod dependencies

## Installation
1. Download the `pp_mams` folder
2. Copy to your X4 extensions directory:
   - Steam: `Documents\Egosoft\X4\<YourPlayerID>\extensions\`
   - GOG/Epic: Similar path in Documents
3. Launch X4 and enable "Pilot Personnel Merit Assignment Management System" in Settings > Extensions
4. Load your save or start a new game

## Configuration
Edit the parameters in `mdscripts/pp_mams.xml`:
- `notify` (default: true) - Show notifications when pilots are assigned
- `logbook` (default: true) - Write assignment events to logbook

## How It Works
1. **New Ship Purchase**: When you buy a ship, the mod:
   - Identifies if it's a battle or non-combat vessel
   - Searches for better pilots in your fleet/PHQ
   - Assigns the best available pilot
   - Moves the original pilot to PHQ service crew

2. **Pilot Loss Events**: When a ship loses its pilot:
   - Automatically triggers the same assignment logic
   - Ensures your ships always have optimal crew

## Testing
- Buy a fighter → Should get your best pilot
- Buy a trader → Should get best crew from PHQ
- Check notifications and logbook for assignment confirmations

## Troubleshooting
- **No assignments happening**: Ensure you have a PHQ built
- **Scripts not running**: Enable debug mode with `-debug scripts -logfile debuglog.txt`
- **Assignment failures**: Check that you have available crew in PHQ

## Technical Details
- Uses Mission Director (MD) for event handling
- Lua scripts handle complex pilot evaluation and assignment
- Piloting skill comparison determines "best" candidates
- Comprehensive error handling prevents save corruption

## Version History
- v1.0 (2025-09-26): Initial release with core functionality

## Support
For issues or feature requests, check the X4 modding community forums.

---
**Note**: This mod does not break save games but assignments only occur after installation. Existing ships are not retroactively optimized.