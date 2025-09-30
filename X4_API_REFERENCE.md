# X4: Foundations API Reference - PP MAMS Cliff Notes

*Auto-generated from JavaScript-scraped PDF documentation*

## Critical Data Type Distinction

### npctemplateentry (Pseudo Data Type)
**Source:** `ship.people.list`, `ship.people.{$npctemplate}`
**Properties:**
- `role` (entityrole) - The NPC's role
- `combinedskill` (0-100) - Current skill for their role
- `potentialskill.{$controlpost}` (0-100) - Potential skill for control posts
- `potentialskill.{$entityrole}` (0-100) - Potential skill for other roles
- `skill.{$skilltype}` (0-15) - Individual skills
- `seed` (largeint) - Unique identifier
- `isbusy`, `isintransit`, `istransferscheduled` - Status flags

**LIMITATION:** Template data only! Does NOT have `.controlpost` property!

### entity (Full Instance)
**Source:** `ship.roleentities`, `ship.roleentity.{$npctemplate}`
**Properties:**
- `controlpost` (controlpost) - **Entity's current control post** (aipilot, manager, engineer)
- `role` (entityrole) - Entity's current role (service, marine, passenger)
- `combinedskill` (0-100) - Combined skill for their control post
- `potentialskill.{$controlpost}` (0-100) - Potential skill for control posts
- `potentialskill.{$entityrole}` (0-100) - Potential skill for roles
- `npctemplate` (npctemplate) - The template for this NPC
- Full entity properties (typename, knownname, etc.)

**USE THIS for iteration when you need controlpost data!**

## Ship Crew Access Methods

### Population Counts
- `ship.people.count` (integer) - Number of people on board
- `ship.people.free` (integer) - Free space for additional crew
- `ship.people.capacity` (integer) - Maximum crew capacity

### Accessing Crew Data

#### Method 1: Template List (npctemplateentry)
```xml
<set_value name="$crew_list" exact="$ship.people.list" />
<do_all exact="$crew_list.count" counter="$i">
  <set_value name="$crew" exact="$crew_list.{$i}" />
  <!-- $crew is npctemplateentry - has role, skills, but NO controlpost -->
</do_all>
```

#### Method 2: Entity List (entity) ⭐ USE THIS!
```xml
<set_value name="$crew_entities" exact="$ship.roleentities" />
<do_all exact="$crew_entities.count" counter="$i">
  <set_value name="$crew_entity" exact="$crew_entities.{$i}" />
  <!-- $crew_entity is entity - has controlpost, role, skills -->
</do_all>
```

#### Method 3: Filtered by Role
```xml
<!-- Get service crew as npctemplateentry -->
<set_value name="$service" exact="$ship.people.{entityrole.service}.list" />
<set_value name="$service_count" exact="$ship.people.{entityrole.service}.count" />
```

### Current Control Positions
- `ship.pilot` (entity) - Current pilot entity
- `ship.controlentity.{controlpost.aipilot}` (entity) - AI pilot
- `ship.controlentity.{controlpost.manager}` (entity) - Manager
- `ship.controlentity.{controlpost.engineer}` (entity) - Engineer
- `ship.controlentity.{controlpost.defence}` (entity) - Defence officer

## Control Posts (controlpost enumeration)

From extracted game files:
- `controlpost.aipilot` - AI Pilot
- `controlpost.manager` - Station/Ship Manager ⚠️ **NEVER TOUCH!**
- `controlpost.engineer` - Engineer
- `controlpost.defence` - Defence Officer
- `controlpost.shiptrader` - Ship Trader
- `controlpost.shadyguy` - Black Marketeer

## Entity Roles (entityrole enumeration)

From extracted game files:
- `entityrole.service` - Service crew
- `entityrole.marine` - Marines
- `entityrole.passenger` - Passengers

## Assignment Command

**Syntax:**
```xml
<assign_control_entity actor="$entity" object="$ship" post="controlpost.aipilot" />
```

**Parameters:**
- `actor` - entity to assign (must be entity, not npctemplateentry!)
- `object` - ship/station to assign to
- `post` - controlpost to assign to
- `transfer` (optional) - boolean, transfer NPC between objects
- `init` (optional) - boolean, initialize assignment

**Example from game files:**
```xml
<assign_control_entity actor="$Argon_Police_Pilot" object="$PoliceShip" post="controlpost.aipilot"/>
```

## Manager Exclusion Logic

**Critical requirement:** Never assign managers to other positions!

```xml
<do_if value="$crew_entity.controlpost != controlpost.manager">
  <!-- Safe to consider for assignment -->
</do_if>
```

**Also exclude already-assigned pilots:**
```xml
<do_if value="$crew_entity.controlpost != controlpost.aipilot">
  <!-- Not currently piloting another ship -->
</do_if>
```

## Skill Sorting

**For pilot selection, use:**
```xml
$crew_entity.potentialskill.{controlpost.aipilot}
```

This returns 0-100 value representing their potential as a pilot.

**MDScript doesn't have built-in sort, so use find-max pattern:**
```xml
<set_value name="$best_candidate" exact="null" />
<set_value name="$best_skill" exact="-1" />

<do_all exact="$candidates.count" counter="$i">
  <set_value name="$candidate" exact="$candidates.{$i}" />
  <set_value name="$skill" exact="$candidate.potentialskill.{controlpost.aipilot}" />

  <do_if value="$skill gt $best_skill">
    <set_value name="$best_candidate" exact="$candidate" />
    <set_value name="$best_skill" exact="$skill" />
  </do_if>
</do_all>
```

## Ship Classification

**For military vs trade logic:**
- `ship.iscapitalship` (boolean) - true if size L or XL
- `ship.purpose` - ship purpose (if available)

## Complete Replacement Flow

```xml
<!-- 1. Get ship that lost pilot -->
<set_value name="$target_ship" exact="$fired_npc.container" />

<!-- 2. Find all player ships -->
<find_object name="$all_ships" class="ship" owner="faction.player" multiple="true" />

<!-- 3. Build candidate pool -->
<set_value name="$candidates" exact="[]" />

<do_all exact="$all_ships.count" counter="$i">
  <set_value name="$ship" exact="$all_ships.{$i}" />

  <!-- Skip ships without crew -->
  <do_if value="$ship.people.count gt 0">

    <!-- Iterate crew entities -->
    <do_all exact="$ship.roleentities.count" counter="$j">
      <set_value name="$crew" exact="$ship.roleentities.{$j}" />

      <!-- Exclude managers -->
      <do_if value="$crew.controlpost != controlpost.manager">

        <!-- Exclude current pilots -->
        <do_if value="$crew.controlpost != controlpost.aipilot">

          <!-- Add to candidate pool -->
          <append_to_list name="$candidates" exact="$crew" />
        </do_if>
      </do_if>
    </do_all>
  </do_if>
</do_all>

<!-- 4. Find best candidate -->
<!-- (use find-max pattern shown above) -->

<!-- 5. Assign -->
<assign_control_entity actor="$best_candidate" object="$target_ship" post="controlpost.aipilot" />
```

## Key Insights

1. **Use `ship.roleentities` for iteration** - gives you entity objects with controlpost
2. **npctemplateentry is template data** - lacks controlpost, can't be used for filtering managers
3. **Manager exclusion is critical** - check `entity.controlpost != controlpost.manager`
4. **assign_control_entity requires entity** - not npctemplateentry
5. **find_object class="ship"** - returns ALL ship-like objects (satellites, probes, missiles) - check people.count!

## Sources

- x4_entity_and_npc.pdf - Entity and NPC properties
- x4_controllable.pdf - Ship crew access methods
- x4_npctemplateentry.pdf - Template data structure
- x4_ship.pdf - Ship-specific properties
- x4_entity_data.pdf - Type and role metadata
- x4_additional_data.pdf - List and collection operations
- x4_cue.pdf - Cue properties
- Extracted game files: /home/meldrey/Projects/x4_extracted_md/