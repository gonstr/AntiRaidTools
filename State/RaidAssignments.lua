local insert = table.insert

local AntiRaidTools = AntiRaidTools

local activeEncounter = nil

-- Key: UUID, value = assignment group index
local activeGroups = {}

-- Key: UnitId, value = { raidAssignment, triggered }
-- We use this so we can do fast lookups for a trigger / raid assignment when a units health changes
local unitHealthRaidAssignmentCache = {}

local function resetRaidAssignments()
    activeEncounter = nil
    activeGroups = {}
    unitHealthTriggersCache = {}
end

function AntiRaidTools:RaidAssignmentsStartEncounter(encounterId)
    resetRaidAssignments()

    if AntiRaidTools:EncounterExists(encounterId) then
        activeEncounter = self.db.profile.data.encounters[encounterId]

        -- Cache unit health triggers for faster lookups
        for _, part in ipairs(activeEncounter) do
            if part.type == "RAID_ASSIGNMENTS" and part.trigger.type == "UNIT_HEALTH" then
                local partCopy = AntiRaidTools:ShallowCopyTable(part)
                partCopy.triggered = false

                unitHealthRaidAssignmentCache[part.trigger.unit] = partCopy
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
            activeGroups[part.uuid] = self:RaidAssignmentsSelectGroup(part.assignments, part.strategy.type)
        end
    end

    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidAssignmentsSelectBestMatchIndex(assignments)
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

function AntiRaidTools:RaidAssignmentsSelectGroup(assignments, strategy)
    local groups = {}

    if strategy == "CHAIN" then
        -- CHAIN uses BEST_MATCH recursivly
        local assignmentsCopy = AntiRaidTools:ShallowCopyTable(assignments)

        local bestMatchIndex = self:RaidAssignmentsSelectBestMatchIndex(assignmentsCopy)
        if bestMatchIndex then assignmentsCopy[bestMatchIndex] = nil end

        while bestMatchIndex do
            insert(groups, bestMatchIndex)

            bestMatchIndex = self:RaidAssignmentsSelectBestMatchIndex(assignmentsCopy)
            if bestMatchIndex then assignmentsCopy[bestMatchIndex] = nil end
        end
    else
        -- Must be BEST_MATCH
        local bestMatchIndex = self:RaidAssignmentsSelectBestMatchIndex(assignments)

        if bestMatchIndex then
            insert(groups, bestMatchIndex)
        end 
    end

    return groups
end

function AntiRaidTools:GetActiveGroups(uuid)
    return activeGroups[uuid]
end

function AntiRaidTools:RaidAssignmentsProcessUnitHealth(unit)
    if activeEncounter then
        local part = unitHealthRaidAssignmentCache[unit]

        if part and not part.triggered then
            local maxHealth = UnitHealthMax(unit)
            local health = UnitHealth(unit)
            local percentage = health / maxHealth * 100

            local trigger = part.trigger

            if percentage < trigger.percentage then
                part.triggered = true

                self:RaidNotificationsShowRaidAssignment(part.uuid)
            end
        end
    end
end
