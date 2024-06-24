local AntiRaidTools = AntiRaidTools

local activeEncounter = nil

-- Key: UUID, value = assignment group index
local activeGroups = {}

-- Key: UnitId, value = { trigger, triggered }
local unitHealthTriggersCache = {}

local function resetRaidCooldowns()
    activeEncounter = nil
    activeGroups = {}
    unitHealthTriggersCache = {}
end

function AntiRaidTools:RaidCooldownsStartEncounter(encounterId)
    if AntiRaidTools:EncounterExists(encounterId) then
        activeEncounter = self.db.profile.data.encounters[encounterId]

        -- Cache unit health triggers for faster lookups
        for _, part in ipairs(activeEncounter) do
            if part.type == "RAID_CDS" and part.trigger.type == "UNIT_HEALTH" then
                unitHealthTriggersCache[part.trigger.unit] = {
                    triggered = false,
                    trigger = unit.trigger
                }
            end
        end

        self:RaidCooldownsProcessGroups()
    end
end

function AntiRaidTools:RaidCooldownsEndEncounter()
    resetRaidCooldowns()
    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidCooldownsProcessGroups()
    if not activeEncounter then
        return
    end

    for i, part in ipairs(activeEncounter) do
        if part.type == "RAID_CDS" then
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

function AntiRaidTools:RaidCooldownsProcessUnitHealth(unit)
    if activeEncounter then
        local unitHealthTrigger = unitHealthTriggersCache[unit]
        if unitHealthTrigger and not unitHealthTrigger.triggered then
            local maxHealth = UnitHealthMax(unit)
            local health = UnitHealth(unit)
            local percentage = health / maxHealth * 100

            if percentage < unitHealthTrigger.trigger.percentage then
                unitHealthTrigger.triggered = true
                --self:RaidNotificationsShow()
            end
        end
    end
end
