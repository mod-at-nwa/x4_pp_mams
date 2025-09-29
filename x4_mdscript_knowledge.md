# X4 MDScript Knowledge Base

## Critical Findings from Debug Analysis

### Player Entity Structure
- `player.entity` = The player character object itself (class=player)
- `player.entity` does NOT have a `.pilot` property (causes "Property lookup failed")
- `player.primaryship` may not exist (causes "Property lookup failed")
- `player.ship` = The ship the player is currently on (may be null if on station)

### Ship Detection Issues

#### find_ship Command Failures
From debug log analysis:
```
[=ERROR=] Error in MD cue md.pp_mams.ScanLoop: Property lookup failed: $player_ships.count
```
This indicates `find_ship` is not returning a valid collection or is returning null.

#### Working Examples from Other Mods
From kuertee_attack_ai_tweaks analysis:
- Uses `find_object_component` NOT `find_ship`
- Accesses pilots via `$Ship.pilot` property
- Uses `$ship.assignedaipilot` for AI-controlled ships

### Pilot Access Patterns

#### Confirmed Working
From kuertee mod:
```xml
<start_script object="$Ship.pilot" name="'orders.base'" />
<debug_text text="'$Ship.pilot: ' + $Ship.pilot + ' ' + $Ship.pilot.knownname" />
```

#### Key Properties
- `$ship.pilot` - Access to the pilot entity
- `$ship.pilot.exists` - Check if pilot exists
- `$ship.pilot.knownname` - Pilot's name
- `$ship.assignedaipilot` - For AI ships

### Find Commands That Work

From successful mods:
```xml
<!-- Find components on specific object -->
<find_object_component object="player.target" name="$modules" multiple="true" class="class.module" />

<!-- Find weapons on ship -->
<find_object_component name="$weapons" object="$ship" class="class.weapon" multiple="true" />

<!-- Find modules -->
<find_module name="$modules" object="$ship" multiple="true" />

<!-- Gravidar contacts (ships in range) -->
<find_gravidar_contact name="$enemies" object="player.target" class="[class.ship_l, class.ship_xl]" />
```

### Why Our Methods Failed

1. **find_ship** - Returns null or invalid collection, `.count` property fails
2. **player.entity.pilot** - Player entity is not a ship, has no pilot property
3. **player.primaryship** - May not exist if player doesn't own a ship

### What We Haven't Tried

1. **find_object_component with faction.player filter**
```xml
<find_object_component name="$ships" space="player.galaxy" owner="faction.player" class="class.ship" multiple="true" />
```

2. **Iterating through player's property list**
- Check if player has a ships collection property
- Use player.occupiedship instead of player.ship

3. **Global ship search with owner filter**
```xml
<find_object name="$allships" space="player.galaxy" class="class.ship" />
<!-- Then filter by owner == faction.player -->
```

## Lessons Learned

### Documentation Issues
- Official wiki pages don't provide MDScript API details
- Forum links were for general modding, not script reference
- Must rely on reverse-engineering working mods

### Debugging Tips
- Use `.exists` checks before accessing properties
- Property lookup failures show exact issue in debug log
- Test multiple methods in parallel to find what works

### Next Steps for PP MAMS

1. Use `find_object_component` with proper parameters
2. Check collection validity with `.exists` before `.count`
3. Access pilots via `$ship.pilot` not other methods
4. Consider searching for ships differently:
   - By scanning zones/sectors
   - By using player's property/subordinates
   - By global search with owner filter