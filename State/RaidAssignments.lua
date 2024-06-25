local AntiRaidTools = AntiRaidTools

local activeEncounter = nil

-- Key: UUID, value = assignment group index
local activeGroups = {}

-- Key: UnitId, value = { raidAssignment, triggered }
local unitHealthTriggersCache = {}

local function resetRaidAssignments()
    activeEncounter = nil
    activeGroups = {}
    unitHealthTriggersCache = {}
end

function AntiRaidTools:RaidAssignmentsStartEncounter(encounterId)
    if AntiRaidTools:EncounterExists(encounterId) then
        activeEncounter = self.db.profile.data.encounters[encounterId]

        -- Cache unit health triggers for faster lookups
        for _, part in ipairs(activeEncounter) do
            if part.type == "RAID_ASSIGNMENTS" and part.trigger.type == "UNIT_HEALTH" then
                unitHealthTriggersCache[part.trigger.unit] = {
                    triggered = false,
                    raidAssignment = part
                }
            end
        end

        self:RaidAssignmentsProcessGroups()
    end
end

function AntiRaidTools:RaidAssignmentsEndEncounter()
    resetRaidAssignments()
    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidAssignmentsProcessGroups()
    if not activeEncounter then
        return
    end

    for i, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" then
            activeGroups[part.uuid] = self:RaidAssignmentsSelectGroup(part.assignments)
        end
    end

    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidAssignmentsSelectGroup(assignments)
    local bestMatchIndex = nil
    local maxReadySpells = 0
    
    -- First pass: check for a group where all assignments are ready
    for i, group in ipairs(assignments) do
        local ready = true
        for _, assignment in ipairs(group) do
            if not self:IsSpellReady(assignment.player, assignment.spell_id) then
                ready = false
                break
            end
        end
        
        if ready then
            return i
        end
    end
    
    -- Second pass: Find the group with the most ready assignemnts
    for i, group in pairs(assignments) do
        local readySpells = 0
        
        for _, assignment in ipairs(group) do
            if self:IsSpellReady(assignment.player, assignment.spell_id) then
                readySpells = readySpells + 1
            end
        end
        
        if readySpells > maxReadySpells then
            bestMatchIndex = i
            maxReadySpells = readySpells
        end
    end

    return bestMatchIndex
end

function AntiRaidTools:GetActiveGroupIndex(uuid)
    return activeGroups[uuid]
end

function AntiRaidTools:RaidAssignmentsProcessUnitHealth(unit)
    if activeEncounter then
        local unitHealthTrigger = unitHealthTriggersCache[unit]
        if unitHealthTrigger and not unitHealthTrigger.triggered then
            local maxHealth = UnitHealthMax(unit)
            local health = UnitHealth(unit)
            local percentage = health / maxHealth * 100

            if percentage < unitHealthTrigger.trigger.percentage then
                unitHealthTrigger.triggered = true
                self:RaidNotificationsShowRaidAssignment(unitHealthTrigger.raidAssignment)
            end
        end
    end
end
