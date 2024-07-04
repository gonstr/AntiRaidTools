local insert = table.insert
local stringFind = string.find

local AntiRaidTools = AntiRaidTools

local activeEncounter = nil

-- We use caches so we can do fast lookups for a trigger
-- key: unitId, value = { raidAssignment, triggered }
local unitHealthTriggersCache = {}

-- key: spellId, value = raidAssignment
local spellCastAssignmentCache = {}

-- key: timer key, value = C_Timer.NewTimer
local fojjiNumenTimers = {}

local function resetState()
    activeEncounter = nil
    unitHealthTriggersCache = {}
    spellCastAssignmentCache = {}

    for key, timer in pairs(fojjiNumenTimers) do
        timer:Cancel()
        fojjiNumenTimers[key] = nil
    end
end

function AntiRaidTools:RaidAssignmentsStartEncounter(encounterId)
    resetState()

    if not self:IsPlayerRaidLeader() then
        return
    end

    activeEncounter = self.db.profile.data.encounters[encounterId]

    if activeEncounter then
        -- Populate caches
        for _, part in ipairs(activeEncounter) do
            if part.type == "RAID_ASSIGNMENTS" then
                if part.trigger.type == "UNIT_HEALTH" then
                    local partCopy = AntiRaidTools:ShallowCopyTable(part)
                    partCopy.triggered = false

                    unitHealthTriggersCache[part.trigger.unit] = partCopy
                elseif part.trigger.type == "SPELL_CAST" then
                    spellCastAssignmentCache[part.trigger.spell_id] = part
                end
            end
        end

        self:RaidAssignmentsUpdateGroups()
    end
end

function AntiRaidTools:RaidAssignmentsEndEncounter()
    resetState()
    self:ResetGroups()
    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidAssignmentsInEncounter()
    return activeEncounter ~= nil
end

function AntiRaidTools:RaidAssignmentsUpdateGroups()
    if not activeEncounter then
        return
    end

    for i, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" then
            self:SetActiveGroup(part.uuid, self:RaidAssignmentsSelectGroup(part.assignments, part.strategy.type))
        end
    end

    self:SendRaidMessage("ACTIVE_GROUPS", self:GetAllActiveGroups())
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

local function sendNotification(uuid, countdown)
    local activeGroups = AntiRaidTools:GetActiveGroups(uuid)

    countdown = countdown or 0

    if activeGroups and #activeGroups > 0 then
        local data = {
            uuid = uuid,
            countdown = countdown
        }

        AntiRaidTools:SendRaidMessage("SHOW_NOTIFICATION", data)
    end
end

function AntiRaidTools:RaidAssignmentsHandleUnitHealth(unit)
    if not activeEncounter then
        return
    end

    local part = unitHealthTriggersCache[unit]

    if part and not part.triggered then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        local percentage = health / maxHealth * 100

        local trigger = part.trigger    

        if percentage < trigger.percentage then
            part.triggered = true

            sendNotification(part.uuid)
        end
    end
end

function AntiRaidTools:RaidAssignmentsHandleSpellCast(event, spellId)
    if not activeEncounter then
        return
    end

    local _, _, _, castTime = GetSpellInfo(spellId)

    -- We don't want to handle a spellcast twice so we only look for start events or success events for instant cast spells
    if event == "SPELL_CAST_START" or (event == "SPELL_CAST_SUCCESS" and (not castTime or castTime == 0)) then
        local part = spellCastAssignmentCache[spellId]

        if part then
            sendNotification(part.uuid)
        end
    end
end

function AntiRaidTools:RaidAssignmentsHandleRaidBossEmote(text)
    if not activeEncounter then
        return
    end

    for _, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" and part.trigger.type == "RAID_BOSS_EMOTE" and stringFind(text, part.trigger.text) ~= nil then
            sendNotification(part.uuid)
        end
    end
end

local function cancelFojjiNumenTimer(key)
    local timer = fojjiNumenTimers[key]

    if timer then
        timer:Cancel()
        fojjiNumenTimers[key] = nil
    end
end

function AntiRaidTools:RaidAssignmentsHandleFojjiNumenTimer(key, countdown)
    if not activeEncounter or not countdown then
        return
    end

    for _, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" and part.trigger.type == "FOJJI_NUMEN_TIMER" and part.trigger.key == key then
            if countdown <= 5 then
                sendNotification(part.uuid, countdown)
            else
                cancelFojjiNumenTimer(key)

                fojjiNumenTimers[key] = C_Timer.NewTimer(countdown - 5, function()
                    sendNotification(part.uuid, 5)
                end)
            end
        end
    end
end
