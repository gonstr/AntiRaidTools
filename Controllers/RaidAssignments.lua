local insert = table.insert
local stringFind = string.find
local tableSort = table.sort

local AntiRaidTools = AntiRaidTools

local activeEncounter = nil

-- We use caches so we can do fast lookups for a trigger
-- key: unitId, value = { raidAssignment, triggered }
local unitHealthTriggersCache = {}

-- key: spellId, value = raidAssignment
local spellCastAssignmentCache = {}

-- key: spellId, value = raidAssignment
local spellAuraAssignmentCache = {}

-- key: timer key, value = C_Timer.NewTimer
local fojjiNumenTimers = {}

local function resetState()
    activeEncounter = nil
    unitHealthTriggersCache = {}
    spellCastAssignmentCache = {}
    spellAuraAssignmentCache = {}

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
        if self.DEBUG then print("[ART] Encounter starting") end

        -- Populate caches
        for _, part in ipairs(activeEncounter) do
            if part.type == "RAID_ASSIGNMENTS" then
                if part.trigger.type == "UNIT_HEALTH" then
                    local partCopy = AntiRaidTools:ShallowCopy(part)
                    partCopy.triggered = false

                    unitHealthTriggersCache[part.trigger.unit] = partCopy
                elseif part.trigger.type == "SPELL_CAST" then
                    spellCastAssignmentCache[part.trigger.spell_id] = part
                elseif part.trigger.type == "SPELL_AURA" then
                    spellAuraAssignmentCache[part.trigger.spell_id] = part
                end
            end
        end

        self:RaidAssignmentsUpdateGroups()
    end
end

function AntiRaidTools:RaidAssignmentsEndEncounter()
    if not activeEncounter then
        return
    end

    if self.DEBUG then print("[ART] Encounter ended") end

    resetState()
    self:ResetGroups()
    self:UpdateOverviewActiveGroups()
end

function AntiRaidTools:RaidAssignmentsInEncounter()
    return activeEncounter ~= nil
end

function AntiRaidTools:RaidAssignmentsIsGroupsEqual(grp1, grp2)
    if grp1 == nil and grp2 == nil then
        return true
    end

    if grp1 == nil or grp2 == nil then
        return false
    end

    if #grp1 ~= #grp2 then
        return false
    end

    local grp1Copy = self:ShallowCopy(grp1)
    local grp2Copy = self:ShallowCopy(grp2)

    tableSort(grp1Copy)
    tableSort(grp2Copy)

    for i = 1, #grp1Copy do
        if grp1Copy[i] ~= grp2Copy[i] then
            return false
        end
    end

    return true
end

function AntiRaidTools:RaidAssignmentsUpdateGroups()
    if not activeEncounter then
        return
    end

    if self.DEBUG then print("[ART] Update groups start") end

    local groupsUpdated = false

    for _, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" then
            local activeGroups = self:GetActiveGroups(part.uuid)
            local selectedGroups = self:RaidAssignmentsSelectGroup(part.assignments, part.strategy.type)

            if not self:RaidAssignmentsIsGroupsEqual(activeGroups, selectedGroups) then
                if self.DEBUG then print("[ART] Updated groups for", part.uuid) end

                groupsUpdated = true
                self:SetActiveGroup(part.uuid, selectedGroups)
            end
        end
    end

    if self.DEBUG then print("[ART] Update groups done:", groupsUpdated) end

    if groupsUpdated then
        self:SendRaidMessage("ACT_GRPS", self:GetAllActiveGroups())
    end
end

function AntiRaidTools:RaidAssignmentsSelectBestMatchIndex(assignments)
    local bestMatchIndex = nil
    local maxReadySpells = 0

    -- First pass: check for a group where all assignments are ready
    for i, group in ipairs(assignments) do
        local ready = true
        for _, assignment in ipairs(group) do
            if not self:IsSpellInUse(assignment.player, assignment.spell_id) and not self:IsSpellReady(assignment.player, assignment.spell_id) then
                ready = false
                break
            end
        end
        
        if ready then
            return i
        end
    end
    
    -- Second pass: Find the group with the most ready assignments
    for i, group in pairs(assignments) do
        local readySpells = 0
        
        for _, assignment in ipairs(group) do
            if self:IsSpellInUse(assignment.player, assignment.spell_id) or self:IsSpellReady(assignment.player, assignment.spell_id) then
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
        local assignmentsCopy = self:ShallowCopy(assignments)

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

function AntiRaidTools:RaidAssignmentsSendNotification(uuid, countdown)
    if self.DEBUG then print("[ART] Sending notification start") end

    local activeGroups = self:GetActiveGroups(uuid)

    countdown = countdown or 0

    if self.DEBUG then
        print("[ART] Notification active groups", activeGroups)
        print("[ART] Notification countdown", countdown)
    end

    if activeGroups and #activeGroups > 0 then
        local data = {
            uuid = uuid,
            countdown = countdown
        }

        if self.DEBUG then print("[ART] Sending notification done") end

        self:SendRaidMessage("NOTIFY", data)
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

        if self.DEBUG then print("[ART] Tracking unit health:", unit, percentage) end

        local trigger = part.trigger    

        if percentage < trigger.percentage then
            part.triggered = true

            self:RaidAssignmentsSendNotification(part.uuid)
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
            if self.DEBUG then print("[ART] Handling spell cast:", spellId) end

            self:RaidAssignmentsSendNotification(part.uuid)
        end
    end
end

function AntiRaidTools:RaidAssignmentsHandleSpellAura(event, spellId)
    if not activeEncounter then
        return
    end

    local part = spellAuraAssignmentCache[spellId]

    if part then
        if self.DEBUG then print("[ART] Handling spell aura:", spellId) end

        self:RaidAssignmentsSendNotification(part.uuid)
    end
end

function AntiRaidTools:RaidAssignmentsHandleRaidBossEmote(text)
    if not activeEncounter then
        return
    end

    for _, part in ipairs(activeEncounter) do
        if part.type == "RAID_ASSIGNMENTS" and part.trigger.type == "RAID_BOSS_EMOTE" and stringFind(text, part.trigger.text) ~= nil then
            if self.DEBUG then print("[ART] Handling raid boss emote:", text) end

            self:RaidAssignmentsSendNotification(part.uuid)
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
            if self.DEBUG then print("[ART] Handling fojji numen timer:", key) end

            if countdown <= 5 then
                self:RaidAssignmentsSendNotification(part.uuid, countdown)
            else
                cancelFojjiNumenTimer(key)

                fojjiNumenTimers[key] = C_Timer.NewTimer(countdown - 5, function()
                    self:RaidAssignmentsSendNotification(part.uuid, 5)
                end)
            end
        end
    end
end
