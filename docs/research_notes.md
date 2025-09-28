### Setting Up the Mod Using the Template

Based on the provided GitHub template for X4 modding, I'll guide you through creating your "Pilot Personnel Merit Assignment Management System" (PP MAMS) mod. The template provides a basic structure for X4 mods, including a `mod_name` folder with subfolders for AI scripts (`aiscripts`) and Mission Director scripts (`mdscripts`), as well as tools like a web server for viewing game data (e.g., jobs.html for ship job properties or scriptproperties.html for script references). It assumes you've extracted X4's CAT files to C:\X4 for reference during development.

The mod will use the Mission Director (MD) to detect new ships and handle pilot assignments. MD is an XML-based scripting system in X4 that can listen for events (like a ship being built) and perform actions. For complex logic (e.g., finding the best pilot or crew), we'll call a custom Lua script. This matches X4 modding practices, where MD handles events and Lua handles detailed queries and manipulations.

Key assumptions based on X4 modding resources:
- Ships are classified as "battle" if their purpose is 'fight' (e.g., fighters, destroyers). Others are non-combat (e.g., trade, mine).
- The "personnel pool" is service crew on the player's Player Headquarters (PHQ). The mod assumes you have a PHQ; if not, assignments may skip or fall back.
- "Highest rated/ranking" means the highest piloting skill.
- "Not critically assigned" means we only pull from non-combat ships or the PHQ pool, avoiding essential roles on combat ships.
- If no suitable pilot/crew is available, the mod falls back to keeping the default pilot (for new ships) or leaving the ship pilotless (rare, but you can expand the Lua to hire new if needed).
- "Suddenly needs a pilot" is handled via the `event_object_crew_changed` event, triggering when a ship loses its pilot (e.g., due to death or reassignment).
- Settings are implemented as MD parameters (editable in the XML file). For in-game checkboxes, you'd need a dependency like "SirNukes Mod Support APIs" to add a custom menu in the Extensions Options screen (ESC > Extension Options). I'll note how to expand for that.

#### Step 1: Download and Prepare the Template
- Go to https://github.com/temetvince/template-x4-mod and clone or download the repository.
- Rename the `mod_name` folder to `pp_mams`.
- Use a text editor (e.g., VS Code with XML extension for autocomplete) to search and replace all instances of "mod_name" with "pp_mams" across files.
- Remove the `aiscripts` folder if it exists (we won't use AI behaviors; everything is MD and Lua).
- Keep file names lowercase for cross-platform compatibility.
- Place the entire `pp_mams` folder in your X4 extensions directory (usually `Documents\Egosoft\X4\<playerID>\extensions\` or the game's mod folder if using Vortex/Steam Workshop).

#### Step 2: Update content.xml
This file registers the mod with X4. Edit `pp_mams/content.xml` to look like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<content id="pp_mams" name="Pilot Personnel Merit Assignment Management System" description="PP MAMS: Automatically assigns pilots to new ships based on merit and conditions. Replaces default pilots and handles sudden pilot needs." author="YourName" version="1.0" date="2025-09-26" save="false">
  <language id="44"/> <!-- English -->
  <mdscript name="pp_mams"/>
</content>
`````

#### Step 3: Create the Mission Director Script
Create or edit ```pp_mams/mdscripts/pp_mams.xml`. This handles events and calls Lua for logic. It includes parameters for your settings (edit the defaults in XML to toggle). For in-game checkboxes, add a dependency on "SirNukes Mod Support APIs" and use its Simple Menu API to create a config menu that sets global variables (e.g., via Lua globals), then reference those in MD with <check_value value="global.notify"/>.

```xml
<mdscript name="pp_mams" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="md.xsd" version="1">
  <params>
    <param name="notify" type="boolean" default="true" desc="Notification on assignment"/>
    <param name="logbook" type="boolean" default="true" desc="Assignment in Logbook"/>
  </params>
  <cues>
    <!-- Cue for new ships: Remove default pilot if better available, triggering crew_changed -->
    <cue name="NewShipAssignment" instantiate="true">
      <conditions>
        <event_object_built object="this.ship" owner="player" class="class.ship"/>
      </conditions>
      <actions>
        <do_if value="this.ship.purpose == 'fight'">
          <call_script name="pp_mams.assign_best_pilot" param.ship="this.ship" param.type="'battle'" return="assigned"/>
        </do_if>
        <do_else>
          <call_script name="pp_mams.assign_best_crew_as_pilot" param.ship="this.ship" param.type="'noncombat'" return="assigned"/>
        </do_else>
        <do_if value="$assigned">
          <do_if value="$notify">
            <show_notification caption="PP MAMS: Pilot Assigned" text="Assigned new pilot to {this.ship.name} based on merit." priority="4"/>
          </do_if>
          <do_if value="$logbook">
            <write_to_logbook category="general" text="PP MAMS: Assigned pilot to {this.ship.name} (Type: {this.ship.purpose})."/>
          </do_if>
        </do_if>
      </actions>
    </cue>

    <!-- Cue for sudden pilot needs: Triggers on crew change, checks if no pilot -->
    <cue name="PilotNeededAssignment" instantiate="true">
      <conditions>
        <event_object_crew_changed object="this.ship"/>
        <check_value value="this.ship.owner == 'player'"/>
        <check_value value="this.ship.class == class.ship"/>
        <check_value value="this.ship.pilot == null"/>
      </conditions>
      <actions>
        <do_if value="this.ship.purpose == 'fight'">
          <call_script name="pp_mams.assign_best_pilot" param.ship="this.ship" param.type="'battle'" return="assigned"/>
        </do_if>
        <do_else>
          <call_script name="pp_mams.assign_best_crew_as_pilot" param.ship="this.ship" param.type="'noncombat'" return="assigned"/>
        </do_else>
        <do_if value="$assigned">
          <do_if value="$notify">
            <show_notification caption="PP MAMS: Pilot Assigned" text="Assigned new pilot to {this.ship.name} based on merit." priority="4"/>
          </do_if>
          <do_if value="$logbook">
            <write_to_logbook category="general" text="PP MAMS: Assigned pilot to {this.ship.name} (Type: {this.ship.purpose})."/>
          </do_if>
        </do_if>
      </actions>
    </cue>
  </cues>
</mdscript>
`````

#### Step 4: Create the Lua Script for Logic
Create a new folder ```pp_mams/libraries` and add `pp_mams.lua`. This file contains functions called from MD. It uses X4's Lua API to query components and move crew. Functions like `GetComponentData`, `GetPilot`, and `ffi.C.MoveCrewToContainer` are standard in X4 modding (decompiled from game scripts). If no better candidate is found, it returns false (no assignment).

```lua
local ffi = require("ffi")
local C = ffi.C

-- Helper to get piloting skill
local function getPilotingSkill(person)
  local skills = GetComponentData(person, "skills")
  return skills and skills.piloting or 0
end

-- Find and assign best pilot for battle ships (scalp from non-combat)
function pp_mams.assign_best_pilot(ship, type)
  local current_pilot = GetPilot(ship)
  local current_skill = current_pilot and getPilotingSkill(current_pilot) or 0

  local best_pilot = nil
  local max_skill = current_skill

  local player_ships = GetOwnedPropertyComponents("player", "ship", true)  -- All player ships
  for _, s in ipairs(player_ships) do
    if s ~= ship then  -- Avoid self
      local purpose = GetComponentData(s, "purpose").primary
      if purpose ~= "fight" then  -- Non-combat
        local pilot = GetPilot(s)
        if pilot then
          local skill = getPilotingSkill(pilot)
          if skill > max_skill then
            max_skill = skill
            best_pilot = pilot
          end
        end
      end
    end
  end

  if best_pilot then
    -- Move best to new ship as pilot
    local ship_id = ConvertStringTo64Bit(tostring(ship))
    local old_ship = GetContainer(best_pilot)
    C.RemovePilot(old_ship)  -- Remove from old
    C.AssignPilot(ship_id, best_pilot)  -- Assign to new
    if current_pilot then
      -- Move default/current to PHQ pool as service crew
      local phq = C.GetPlayerHQ()
      if phq then
        C.MoveCrewToContainer(phq, current_pilot)
        C.AssignCrewToRole(phq, current_pilot, "servicecrew")
      else
        C.RemoveCrewMember(ship_id, current_pilot)  -- Fallback: remove if no PHQ
      end
    end
    return true
  end
  return false  -- No assignment if no better
end

-- Assign best crew as pilot for non-combat (promote from pool)
function pp_mams.assign_best_crew_as_pilot(ship, type)
  local current_pilot = GetPilot(ship)
  local current_skill = current_pilot and getPilotingSkill(current_pilot) or 0

  local phq = C.GetPlayerHQ()
  if not phq then return false end  -- No PHQ, skip

  local best_crew = nil
  local max_skill = current_skill

  local crew_list = GetCrewTable(phq)  -- All crew on PHQ
  for _, crew in ipairs(crew_list) do
    local role = GetComponentData(crew, "role")
    if role == "servicecrew" then  -- Available in pool
      local skill = getPilotingSkill(crew)
      if skill > max_skill then
        max_skill = skill
        best_crew = crew
      end
    end
  end

  if best_crew then
    -- Move and assign as pilot
    local ship_id = ConvertStringTo64Bit(tostring(ship))
    C.MoveCrewToContainer(ship_id, best_crew)
    C.AssignPilot(ship_id, best_crew)
    if current_pilot then
      -- Move default back to pool
      C.MoveCrewToContainer(phq, current_pilot)
      C.AssignCrewToRole(phq, current_pilot, "servicecrew")
    end
    return true
  end
  return false
end
`````

#### Step 5: Testing and Deployment
- Run ```webserver.bat` (from template) to view X4 data like script properties for debugging.
- Load X4, enable the mod in Settings > Extensions.
- Test by buying a ship: It should auto-assign per rules, with notifications/logs if enabled.
- If adding in-game checkboxes: Install "SirNukes Mod Support APIs" as a dependency. Add a UI Lua script (e.g., in `pp_mams/ui/additions/`) using its Simple Menu API to toggle globals like `Menu.notify = true`, then check them in MD actions.
- Package as a .zip for Steam Workshop/Nexus: Include the `pp_mams` folder and README with instructions.
- Exe flags from template (for testing): Use `-debug scripts -logfile debuglog.txt` to log script errors.

This should give you a functional mod. If issues arise (e.g., API function names vary slightly), check Egosoft forums for exact Lua calls or adjust based on debug logs. Let me know if you need tweaks!)
