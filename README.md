# Pilot Personnel Merit Assignment Management System (PP MAMS)

An X4: Foundations mod that automatically assigns optimal pilots to newly purchased ships based on merit and specific conditions.

## Features

- **Merit-Based Assignment**: Assigns pilots based on actual piloting skill ratings
- **Battle Ship Priority**: Combat vessels get the highest skilled pilots available
- **Smart Scalping**: Battle ships can recruit pilots from non-combat vessels when needed
- **Non-Combat Optimization**: Trade/mining ships get the best available crew from PHQ pool
- **Configurable Notifications**: Enable/disable in-game notifications and logbook entries
- **Save Game Safe**: Event-driven architecture that doesn't break existing saves

## How It Works

### Ship Classification
- **Battle Ships** (`purpose == 'fight'`): Fighters, destroyers, carriers
  - Get highest skilled pilots available
  - Can recruit from non-combat ships if needed
- **Non-Combat Ships**: Traders, miners, builders, etc.
  - Get best available crew from PHQ service pool
  - Protected from pilot recruitment by battle ships

### Assignment Logic
1. **New Ship Purchase**: When you buy a ship, PP MAMS:
   - Identifies if it's a battle or non-combat vessel
   - Searches for better pilots in your fleet/PHQ
   - Assigns the best available pilot based on piloting skill
   - Moves the original pilot to PHQ service crew

2. **Pilot Loss Events**: When a ship loses its pilot:
   - Automatically triggers the same assignment logic
   - Ensures your ships always have optimal crew

## Installation

### From Release
1. Download the latest release from [Releases](../../releases)
2. Extract the `pp_mams` folder
3. Copy to your X4 extensions directory:
   - **Steam**: `Documents\Egosoft\X4\<YourPlayerID>\extensions\`
   - **GOG/Epic**: Similar path in Documents folder
4. Launch X4 and enable "Pilot Personnel Merit Assignment Management System" in Settings > Extensions
5. Load your save or start a new game

### From Source
```bash
git clone https://github.com/meldrey/PRJ-369-017-x4_pp_mams.git
cp -r PRJ-369-017-x4_pp_mams/pp_mams ~/Documents/Egosoft/X4/<YourPlayerID>/extensions/
```

## Configuration

Edit parameters in `pp_mams/md/pp_mams.xml`:
- `notify` (default: true) - Show notifications when pilots are assigned
- `logbook` (default: true) - Write assignment events to logbook

## Requirements

- X4: Foundations (version 7.00+)
- Player Headquarters (PHQ) recommended for optimal functionality
- No other mod dependencies

## Testing

- **Restart X4** → Load v1.11 (clears cached XML errors)
- **Fire a pilot** → Within 30 seconds, PP MAMS will detect and reassign automatically
- **Buy a new ship** → Periodic checks will optimize pilots within 30 seconds
- **Check debug log** → Should show "version 1.11" and periodic scanning messages
- **Monitor notifications** → Assignment confirmations appear when pilots are reassigned

## Troubleshooting

- **XML errors in log**: Restart X4 to clear cached files from older versions
- **No assignments happening**: Ensure you have a PHQ built with service crew
- **Periodic checks not running**: Check debug log for "Starting periodic ship monitoring system"
- **Version mismatch**: Look for "version 1.11" in debug log to confirm latest version loaded
- **Scripts not running**: Enable debug mode: `-debug scripts -logfile debuglog.txt`
- **Assignment failures**: Check that you have available crew in PHQ

## Technical Details

- **Mission Director (MD)**: Pure XML-based event handling with periodic monitoring
- **Automatic Detection**: 30-second interval scanning for suboptimal pilots (skill < 3)
- **Skill Evaluation**: Piloting skill comparison determines optimal candidates
- **Event Architecture**: Uses `event_cue_signalled` with `delay` for proper timing
- **Error Handling**: Comprehensive safeguards prevent save corruption

## Development

### Project Structure
```
pp_mams/
├── content.xml              # Mod registration and metadata
├── md/
│   └── pp_mams.xml         # Mission Director event handling
└── README.md               # End-user documentation
install_mod.sh               # Installation script for development
debug_log_analyzer.sh        # Debug log analysis tool
```

### Testing
Run X4 with debug flags to monitor script execution:
```bash
X4.exe -debug scripts -logfile debuglog.txt
```

## Version History

- **v1.11** (2025-09-28): Fixed XML validation errors with working automatic monitoring
  - **FIXED**: All XML validation errors resolved - mod loads without errors
  - **NEW**: Automatic periodic ship monitoring every 30 seconds
  - **IMPROVED**: No console commands required - fully automatic operation
  - **TECHNICAL**: Proper event handling using `event_cue_signalled` and `delay`
  - **ENHANCED**: Smart detection of ships needing better pilots (skill < 3 or no pilot)
  - Restart X4 required to clear cached XML errors from previous versions
- **v1.10** (2025-09-28): First attempt at periodic monitoring (had XML errors)
- **v1.09** (2025-09-28): Attempted console-based manual triggers (not viable in X4)
- **v1.08** (2025-09-28): Critical XML syntax fixes for pilot firing functionality
  - **CRITICAL**: Fixed missing `object` attributes causing XML parsing errors
  - Changed `event_object_changed_owner` to `event_player_owned_object_changed_owner`
  - Removed invalid `object="player.galaxy"` from `find_object_component` elements
  - XML validation now passes completely - mod functions properly when pilots are fired
  - Pilot reassignment now triggers correctly on ownership changes
- **v1.07** (2025-09-28): Major pilot assignment bug fixes and installation cleanup
  - **CRITICAL**: Fixed invalid `assign_pilot` actions causing mod failures
  - Replaced `assign_pilot` with correct `assign_control_entity` X4 syntax
  - Created installation script (`install_mod.sh`) for proper deployment
  - Cleaned up conflicting multiple installations (removed v1.02/v1.05/v1.06 conflicts)
  - Removed duplicate `/mdscripts/` directory causing version conflicts
  - Pilot assignment now works correctly without XML lookup errors
- **v1.06** (2025-09-28): Intermediate fix attempt (superseded by v1.07)
- **v1.05** (2025-09-28): Fixed MDScript syntax errors - pilot firing now works correctly
  - Removed invalid `event_object_pilot_changed` event (doesn't exist in X4)
  - Fixed `remove_pilot` actions to use correct `destroy_object` syntax
  - All MDScript validation errors resolved
  - Pilot management functionality now fully operational
- **v1.04** (2025-09-28): Full pilot management system implementation
  - Event-driven pilot assignment using pure Mission Director XML
  - Battle ship priority pilot assignment (scalp from non-combat ships)
  - Non-combat ship crew promotion from PHQ service pool
  - Automatic pilot optimization on ship acquisition and pilot changes
  - Extensive debug logging and user feedback system
  - Fixed mod loading issues by removing Lua dependencies
- **v1.03** (2025-09-28): Structural fixes for X4 compatibility
  - Renamed mdscripts/ to md/ directory (X4 standard)
  - Removed mdscript tags from content.xml
  - Fixed MD script syntax errors
- **v1.02** (2025-09-28): Basic loading and initialization
  - Removed problematic Lua library declarations
  - Fixed XML validation errors
  - Basic mod loading with initialization cue
- **v1.0** (2025-09-26): Initial release with core functionality

## Contributing

Issues and pull requests welcome. Please follow X4 modding conventions and test thoroughly before submitting.

## License

This project is open source. See [LICENSE](LICENSE) for details.

## Credits

- **Author**: Meldrey
- **Development Team**: Claude Code
- **Special Thanks**: X4 modding community for templates and guidance

## Support

For issues or feature requests:
- Open an issue on this repository
- Visit the X4 modding community forums
- Check the [troubleshooting section](#troubleshooting) above

---

**Note**: This mod does not break save games, but assignments only occur after installation. Existing ships are not retroactively optimized.