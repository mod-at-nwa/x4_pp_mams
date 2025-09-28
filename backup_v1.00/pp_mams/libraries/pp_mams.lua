-- PP MAMS Lua Library Module
local ffi = require("ffi")
local C = ffi.C

-- Initialize module table
local pp_mams = {}

-- Helper to get piloting skill with error handling
local function getPilotingSkill(person)
  if not person then return 0 end

  local success, skills = pcall(GetComponentData, person, "skills")
  if not success or not skills then return 0 end

  return skills.piloting or 0
end

-- Find and assign best pilot for battle ships (scalp from non-combat)
function pp_mams.assign_best_pilot(param)
  local ship = param[1]
  local type = param[2]
  DebugError("PP MAMS: assign_best_pilot called for " .. tostring(ship))
  if not ship then
    DebugError("PP MAMS: No ship provided to assign_best_pilot")
    return false
  end

  local current_pilot = GetPilot(ship)
  local current_skill = current_pilot and getPilotingSkill(current_pilot) or 0
  DebugError("PP MAMS: Current pilot skill: " .. current_skill)

  local best_pilot = nil
  local best_ship = nil
  local max_skill = current_skill

  -- Search through all player ships for better pilots on non-combat vessels
  local success, player_ships = pcall(GetOwnedPropertyComponents, "player", "ship", true)
  if not success or not player_ships then return false end

  for _, s in ipairs(player_ships) do
    if s ~= ship then  -- Avoid self
      local ship_data = GetComponentData(s, "purpose")
      if ship_data and ship_data.primary then
        local purpose = ship_data.primary
        if purpose ~= "fight" then  -- Non-combat ship
          local pilot = GetPilot(s)
          if pilot then
            local skill = getPilotingSkill(pilot)
            if skill > max_skill then
              max_skill = skill
              best_pilot = pilot
              best_ship = s
            end
          end
        end
      end
    end
  end

  -- If we found a better pilot, perform the assignment
  if best_pilot and best_ship then
    local ship_id = ConvertStringTo64Bit(tostring(ship))
    local best_ship_id = ConvertStringTo64Bit(tostring(best_ship))

    -- Remove pilot from source ship
    local success1 = pcall(C.RemovePilot, best_ship_id)
    if not success1 then return false end

    -- Assign to new ship
    local success2 = pcall(C.AssignPilot, ship_id, best_pilot)
    if not success2 then
      -- Try to restore pilot to original ship if assignment failed
      pcall(C.AssignPilot, best_ship_id, best_pilot)
      return false
    end

    -- Handle current pilot (move to PHQ or remove)
    if current_pilot then
      local phq = C.GetPlayerHQ()
      if phq then
        local phq_id = ConvertStringTo64Bit(tostring(phq))
        pcall(C.MoveCrewToContainer, phq_id, current_pilot)
        pcall(C.AssignCrewToRole, phq_id, current_pilot, "servicecrew")
      else
        -- Fallback: remove if no PHQ
        pcall(C.RemoveCrewMember, ship_id, current_pilot)
      end
    end

    return true
  end

  return false  -- No better pilot found
end

-- Assign best crew as pilot for non-combat ships (promote from PHQ pool)
function pp_mams.assign_best_crew_as_pilot(param)
  local ship = param[1]
  local type = param[2]
  DebugError("PP MAMS: assign_best_crew_as_pilot called for " .. tostring(ship))
  if not ship then
    DebugError("PP MAMS: No ship provided to assign_best_crew_as_pilot")
    return false
  end

  local current_pilot = GetPilot(ship)
  local current_skill = current_pilot and getPilotingSkill(current_pilot) or 0
  DebugError("PP MAMS: Current pilot skill: " .. current_skill)

  -- Check for PHQ existence
  local phq = C.GetPlayerHQ()
  if not phq then return false end  -- No PHQ, skip

  local best_crew = nil
  local max_skill = current_skill

  -- Search PHQ crew for better candidates
  local success, crew_list = pcall(GetCrewTable, phq)
  if not success or not crew_list then return false end

  for _, crew in ipairs(crew_list) do
    local crew_data = GetComponentData(crew, "role")
    if crew_data == "servicecrew" then  -- Available in pool
      local skill = getPilotingSkill(crew)
      if skill > max_skill then
        max_skill = skill
        best_crew = crew
      end
    end
  end

  -- If we found better crew, perform assignment
  if best_crew then
    local ship_id = ConvertStringTo64Bit(tostring(ship))
    local phq_id = ConvertStringTo64Bit(tostring(phq))

    -- Move crew to ship and assign as pilot
    local success1 = pcall(C.MoveCrewToContainer, ship_id, best_crew)
    if not success1 then return false end

    local success2 = pcall(C.AssignPilot, ship_id, best_crew)
    if not success2 then
      -- Try to restore crew to PHQ if assignment failed
      pcall(C.MoveCrewToContainer, phq_id, best_crew)
      pcall(C.AssignCrewToRole, phq_id, best_crew, "servicecrew")
      return false
    end

    -- Handle current pilot (move back to PHQ pool)
    if current_pilot then
      pcall(C.MoveCrewToContainer, phq_id, current_pilot)
      pcall(C.AssignCrewToRole, phq_id, current_pilot, "servicecrew")
    end

    return true
  end

  return false  -- No better crew found
end

-- Return the module table for X4's library system
return pp_mams