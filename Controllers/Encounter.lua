local addonName, addon = ...

local insert = table.insert

local AceEvent = LibStub("AceEvent-3.0")

addon.EncounterControllerPrototype = {}

local EncounterController = addon.EncounterControllerPrototype
EncounterController.__index = EncounterController

local function TriggersCacheKey(type, arg)
    return type .. "." .. arg
end

local function TriggersCacheKeyForTrigger(trigger)
    if trigger.type == "UNIT_HEALTH" then
        return TriggersCacheKey(trigger.type, trigger.unit)
    elseif trigger.type == "SPELL_CAST" or trigger.type == "SPELL_AURA" then
        return TriggersCacheKey(trigger.type, trigger.spellId)
    elseif trigger.type == "EMOTE_OR_YELL" then
        return TriggersCacheKey(trigger.type, trigger.text)
    end

    error("Unknown trigger type: " .. trigger.type)
end

function EncounterController:New(db, utils)
    local instance = setmetatable({}, self)

    instance.db = db
    instance.utils = utils

    AceEvent:Embed(instance)

    instance:RegisterEvent("ENCOUNTER_START")
    instance:RegisterEvent("ENCOUNTER_END")
    instance:RegisterEvent("PLAYER_REGEN_ENABLED")
    instance:RegisterEvent("UNIT_HEALTH")
    instance:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    instance:RegisterEvent("RAID_BOSS_EMOTE")
    instance:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    instance:RegisterEvent("CHAT_MSG_MONSTER_YELL")

    instance:Reset()

    return instance
end

function EncounterController:Stop()
    addon:Debug("EncounterController:Stop")

    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("RAID_BOSS_EMOTE")
    self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
end

function EncounterController:Reset()
    addon:Debug("EncounterController:Reset")

    self.inEncounter = false
    self.triggersCache = {}
end

function EncounterController:ENCOUNTER_START(_, encounterId)
    addon:Debug("EncounterController:ENCOUNTER_START", encounterId)
    
    self:Reset()

    -- Populate triggers cache
    for _, pack in pairs(self.db.profile.v1.packs) do
        for _, item in ipairs(pack.items) do
            if item.type == "TRIGGER" and item.encounter == encounterId then
                for _, trigger in ipairs(item.triggers) do
                    local clone = self.utils:DeepClone(trigger)

                    local cacheKey = TriggersCacheKeyForTrigger(clone)

                    if not self.triggersCache[cacheKey] then
                        self.triggersCache[cacheKey] = {}
                    end

                    insert(self.triggersCache[cacheKey] , clone)
                end

                for _, untrigger in ipairs(item.untriggers) do
                    local clone = self.utils:DeepClone(untrigger)

                    local cacheKey = TriggersCacheKeyForTrigger(clone)

                    if not self.triggersCache[cacheKey] then
                        self.triggersCache[cacheKey] = {}
                    end

                    -- We set `isUntrigger` true to mark that this as an untrigger.
                    -- Internally triggers and untriggers are the same thing so it make
                    -- sense to just add them to the triggers cache here.
                    clone.isUntrigger = true
                    
                    insert(self.triggersCache[cacheKey], clone)
                end
            end
        end
    end

    self.inEncounter = true
end

function EncounterController:ENCOUNTER_END()
    addon:Debug("EncounterController:ENCOUNTER_END", encounterId)

    self:Reset()
end

function EncounterController:PLAYER_REGEN_ENABLED()
    addon:Debug("EncounterController:PLAYER_REGEN_ENABLED")

    if self.inEncounter then
        -- This is just another way of registering an encounter ending
        if not UnitIsDeadOrGhost("player") then
            self:Reset()
        end
    end
end

function EncounterController:UNIT_HEALTH(_, unitId)
    if self.inEncounter then
        addon:Debug("EncounterController:UNIT_HEALTH", unitId)

        local triggers = self.triggersCache[TriggersCacheKey("UNIT_HEALTH", unitId)]

        if triggers then
            for _, trigger in ipairs(triggers) do
                if trigger.unit == unitId then
                    -- We only allow unit health triggers to trigger once
                    if not trigger.triggered then
                        local health = UnitHealth(unitId)
                        local maxHealth = UnitHealthMax(unitId)
                        local pct = health / maxHealth * 100
                
                        if (trigger.lessThan and health < trigger.lessThan)
                        or (trigger.greaterThan and health > trigger.greaterThan)
                        or (trigger.lessThanPct and pct < trigger.lessThanPct)
                        or (trigger.greaterThanpct and pct > trigger.greaterThanPct)
                        then
                            trigger.triggered = true
                            addon:SendMessage(addon.MESSAGES.ART_TRIGGER, trigger)
                        end
                    end
                end
            end
        end
    end
end

function EncounterController:COMBAT_LOG_EVENT_UNFILTERED()
    if self.inEncounter then
        addon:Debug("EncounterController:COMBAT_LOG_EVENT_UNFILTERED")

        local _, subEvent, _, _, sourceName, _, _, destGUID, destName, _, _, spellId = CombatLogGetCurrentEventInfo()

        if subEvent == "SPELL_CAST_START" or subEvent == "SPELL_CAST_SUCCESS" then
            self:HandleSpellCast(subEvent, spellId)
        elseif subEvent == "SPELL_AURA_APPLIED" then
            self:HandleSpellAura(spellId)
        end
    end
end

function EncounterController:HandleSpellCast(subEvent, spellId)
    addon:Debug("EncounterController:HandleSpellCast", { subEvent = subEvent, spellId = spellId })

    local triggers = self.triggersCache[TriggersCacheKey("SPELL_CAST", spellId)]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if trigger.spellId == spellId then
                local _, _, _, castTime = GetSpellInfo(spellId)

                -- We don't want to handle a spell casts twice so we only look for start events or success events for instant cast spells
                if subEvent == "SPELL_CAST_START" or (subEvent == "SPELL_CAST_SUCCESS" and castTime > 0) then
                    addon:SendMessage(addon.MESSAGES.ART_TRIGGER, trigger)
                end
            end
        end
    end
end

function EncounterController:HandleSpellAura(spellId)
    addon:Debug("EncounterController:HandleSpellAura", spellId)

    local triggers = self.triggersCache[TriggersCacheKey("SPELL_AURA", spellId)]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if trigger.spellId == spellId then
                addon:SendMessage(addon.MESSAGES.ART_TRIGGER, trigger)
            end
        end
    end
end

function EncounterController:RAID_BOSS_EMOTE(_, text)
    if self.inEncounter then
        addon:Debug("EncounterController:RAID_BOSS_EMOTE", text)

        self:HandleEmoteOrYell(text)
    end
end

function EncounterController:CHAT_MSG_RAID_BOSS_EMOTE(_, text)
    if self.inEncounter then    
        addon:Debug("EncounterController:RAID_BOSS_EMOTE", text)

        self:HandleEmoteOrYell(text)
    end
end

function EncounterController:CHAT_MSG_MONSTER_YELL(_, text)
    if self.inEncounter then
        addon:Debug("EncounterController:CHAT_MSG_MONSTER_YELL", text)

        self:HandleEmoteOrYell(text)
    end
end

function EncounterController:HandleEmoteOrYell(text)
    addon:Debug("EncounterController:HandleEmoteOrYell", text)

    local triggers = self.triggersCache[TriggersCacheKey("EMOTE_OR_YELL", text)]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if text:match(trigger.text) ~= nil then
                addon:SendMessage(addon.MESSAGES.ART_TRIGGER, trigger)
            end
        end
    end
end
