# PP MAMS - Pilot Personnel Merit Assignment Management System

**Version 3.51** - A hard-won X4: Foundations mod for automatic pilot replacement based on merit.

## What It Does

PP MAMS (Pilot Personnel Merit Assignment Management System) automatically assigns the best available pilot from your fleet when you fire a pilot from any ship. No more manual searching through dozens of ships to find your best pilot - PP MAMS handles it automatically based on skill level.

### Core Features
- **Automatic Pilot Replacement**: When you fire a pilot, PP MAMS instantly finds and assigns your best available pilot
- **Merit-Based Selection**: Pilots are ranked by their skill level (`potentialskill.{controlpost.aipilot}`)
- **Smart Filtering**: Protects important crew:
  - Never touches station managers
  - Excludes large ships (L/XL class)
  - Excludes combat ships (purpose.fight)
  - Preserves your capital ship and combat vessel crews

## The Journey

This mod represents 51 iterations of blood, sweat, and "son of a chip" moments. From v3.26 to v3.51, we battled:
- X4's undocumented MDScript API
- Event timing nightmares (`event_conversation_next_section` fires BEFORE pilot removal!)
- Property lookup failures galore
- Null reference exceptions that made grown developers cry
- The discovery that `boardingmarines.count` returns 0 for ships WITHOUT the capability

### Key Milestones
- **v3.26-v3.34**: Failed attempts at accessing crew properties
- **v3.35-v3.40**: API discovery phase (TEST 1-10)
- **v3.41**: First successful pilot detection
- **v3.42-v3.47**: Wrestling with async event timing
- **v3.48**: FIRST SUCCESSFUL PILOT TRANSFER! 🎉
- **v3.49-v3.51**: Protection mechanisms for special ships

## How It Works

### Technical Architecture
1. **Detection**: Listens for `event_conversation_next_section` with `g_pilotleave` parameter
2. **Signaling**: Top-level cue signals a handler with the ship reference
3. **Waiting**: Child cue waits for `event_control_entity_removed` on that specific ship
4. **Search**: Scans all player ships for eligible pilots
5. **Selection**: Chooses highest skill pilot from eligible candidates
6. **Assignment**: Uses `assign_control_entity` with `transfer="true"`

### Filters Applied (v3.51)
1. Ship must be different from target
2. Ship class must be S or M (small/medium)
3. Ship purpose must NOT be combat (purpose.fight)
4. NPC must NOT be a station manager
5. NPC must have pilot skill > 0

## Installation

1. Download the mod files from this repository
2. Extract to your X4 extensions folder:
   ```
   X4 Foundations/extensions/pp_mams/
   ```
3. The mod structure should be:
   ```
   pp_mams/
   ├── content.xml
   ├── ext_01.cat
   └── ext_01.dat
   ```
4. Launch X4 and load your save
5. Fire a pilot to test!

## Building from Source

The repository includes the source MDScript files and a packing script:

```bash
python3 pack_mod.py
```

This will create the CAT/DAT files in `pp_mams_packed/`.

## Known Issues & Future Work

### What's Left to Fix

1. **Exclusion Mechanisms**
   - The current filter may not catch all special-purpose ships
   - Manticore protection needs refinement (currently relies on purpose filtering)
   - Consider adding a configurable exclusion list

2. **Secondary Vacancy Chain**
   - When PP MAMS pulls a pilot from Ship A to fill Ship B, Ship A is left without a pilot
   - Should trigger another search to fill the newly created vacancy
   - Risk of cascade effects needs management

3. **Edge Cases**
   - Property lookup failures still occur with destroyed/invalid ships
   - Yoshiko tracker has null reference issues (Easter egg debug feature)
   - Some modded ships may not be properly filtered

### Debug Features
The mod includes comprehensive debug output in v3.50+ showing:
- Source ship details (name, class, macro, purpose)
- Pilot information (name, skill, role)
- Target ship information
- This helps diagnose any unexpected pilot transfers

## Technical Discoveries

### The Event Problem
X4's MDScript has NO direct pilot/crew events. After extracting and analyzing the entire game codebase:
- No `event_pilot_fired` or `event_crew_changed` exists
- `event_conversation_next_section` was our salvation
- But it fires BEFORE the pilot is removed (async signal issue)
- Solution: Wait for `event_control_entity_removed` after detection

### The API Mystery
Accessing crew properties was a nightmare:
- `ship.people.list` exists but items have no accessible properties
- `find_object_component` with `class.npc` was the key
- `potentialskill.{controlpost.aipilot}` gives pilot skill
- But only after 10+ test iterations to discover the syntax

## Why Not on Steam?

This mod is released on GitHub rather than Steam Workshop due to privacy concerns with Steam's data collection practices. The code is open source and free for anyone to use, modify, and distribute.

## Credits

- **Developer**: Meldrey
- **AI Assistant**: Claude (Anthropic)
- **Special Recognition**: The 51 iterations that died so this mod could live
- **Inspired By**: Every X4 player who ever thought "Why can't the game just pick the best pilot?"

## License

This mod is released into the public domain. Do whatever you want with it. May your pilots always fly true.

## Final Words

*"We did it. Yeah, I said we. Definitely we."* - Meldrey, upon first successful pilot transfer

*"Claude, you son of a chip. We did it."* - Meldrey, after v3.48

The struggle was real. The victory was earned. Fire a pilot, get your best replacement. That's PP MAMS.