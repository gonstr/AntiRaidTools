local AntiRaidTools = AntiRaidTools

local activeEncounter = nil

-- Key: UUID, value = assignment group index
local activeGroups = {}

local function resetCooldowns()
    activeEncounter = nil
    activeGroups = {}
end

function AntiRaidTools:RaidCooldownsStartEncounter(encounterId)
    if AntiRaidTools:EncounterExists(encounterId) then
        activeEncounter = self.db.profile.data.encounters[encounterId]
        self:RaidCooldownsProcessGroups()
    end
end

function AntiRaidTools:RaidCooldownsEndEncounter()
    resetCooldowns()
    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidCooldownsProcessGroups()
    if not activeEncounter then
        return
    end

    for i, part in ipairs(activeEncounter) do
        if part.type == "RAID_CDS" and part.strategy.type == "BEST_MATCH" then
            activeGroups[part.uuid] = self:RaidCooldownsSelectGroup(part.assignments)
        end
    end

    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidCooldownsSelectGroup(assignments)
    local bestMatchIndex = nil
    local maxReadySpells = 0
    
    -- First pass: check for a group where all CDs are ready
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
    
    -- Second pass: Find the group with the most ready CDs
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
