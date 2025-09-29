# Pilot Personnel Merit Assignment Management System (PP MAMS)

## Overview
PP MAMS is an X4: Foundations mod that automatically monitors your fleet every 30 seconds and assigns optimal pilots based on merit and ship requirements. The mod intelligently manages pilot assignments to ensure your ships always have the best available crew.

## Features
- **Automatic Fleet Monitoring**: Scans your fleet every 30 seconds for pilot optimization opportunities
- **Merit-Based Assignment**: Assigns pilots based on actual piloting skill ratings (minimum skill 3)
- **Battle Ship Priority**: Combat vessels get the highest skilled pilots available
- **Non-Combat Optimization**: Trade/mining ships get the best available crew from PHQ pool
- **Smart Pilot Swapping**: Battle ships can take pilots from non-combat vessels if needed
- **Configurable Notifications**: Enable/disable in-game notifications and logbook entries
- **Real-time Processing**: Continuously maintains optimal pilot assignments

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
1. **Periodic Fleet Monitoring**: Every 30 seconds, the mod:
   - Scans all player ships for pilot optimization opportunities
   - Identifies ships without pilots or with pilots below skill 3
   - Triggers appropriate assignment logic based on ship type

2. **Battle Ship Assignment**: For combat vessels:
   - Searches through all non-combat ships for better pilots
   - Swaps the best available pilot to the battle ship
   - Original pilots remain on their previous ships

3. **Non-Combat Assignment**: For trade/mining ships:
   - Searches PHQ crew for available personnel
   - Promotes the best crew member to pilot position
   - Uses assign_control_entity for seamless transitions

## Testing
- Wait 30 seconds after loading → Automatic fleet scan begins
- Buy ships with poor pilots → Should be upgraded automatically on next scan
- Fire pilots from ships → Replacements assigned on next monitoring cycle
- Check notifications and logbook for assignment confirmations
- Use debug command: Signal player with 'pp_mams_test' to trigger immediate scan

## Troubleshooting
- **No assignments happening**: Ensure you have a PHQ built
- **Scripts not running**: Enable debug mode with `-debug scripts -logfile debuglog.txt`
- **Assignment failures**: Check that you have available crew in PHQ

## Technical Details
- Uses Mission Director (MD) for periodic fleet monitoring
- Event-driven architecture with 30-second scanning intervals
- Piloting skill comparison determines "best" candidates (skill level 3+ required)
- Direct assign_control_entity usage for reliable pilot assignments
- Comprehensive debug logging for troubleshooting

## Version History
- v1.13 (2025-09-28): **CURRENT** - Fixed invalid remove_pilot commands, improved pilot assignment reliability
- v1.12 (2025-09-28): Fixed pilot firing issues with proper PHQ transfers and cue signaling
- v1.11 (2025-09-28): Fixed XML validation errors and periodic monitoring system
- v1.08 (2025-09-28): Critical XML syntax fixes for pilot firing functionality
- v1.07 (2025-09-28): Fixed pilot assignment bugs and installation cleanup
- v1.04 (2025-09-28): Full pilot management system implementation
- v1.0 (2025-09-26): Initial release with core functionality

## Support
For issues or feature requests, check the X4 modding community forums.

---
**Note**: This mod does not break save games but assignments only occur after installation. Existing ships are not retroactively optimized.