local addonName, addon = ...

local insert = table.insert

addon.ImportValidatorPrototype = {}

local ImportValidator = addon.ImportValidatorPrototype
ImportValidator.__index = ImportValidator

local function toString(thing, indent)
    if type(thing) ~= "table" then
        return thing or ""
    end

    local result = {}
    local indent = indent or 0
    local padding = string.rep("  ", indent)
    
    table.insert(result, "{\n")
    
    for k, v in pairs(thing) do
        local key
        if type(k) == "string" then
            key = string.format("%s[%q] = ", padding, k)
        else
            key = string.format("%s[%s] = ", padding, toString(k))
        end
        
        local value
        if type(v) == "table" then
            value = toString(v, indent + 1)
        elseif type(v) == "string" then
            value = string.format("%q", v)
        else
            value = toString(v)
        end
        
        table.insert(result, key .. value .. ",\n")
    end
    
    table.insert(result, padding .. "}")
    
    return table.concat(result)
end

function ImportValidator:new(utils)
    local instance = setmetatable({}, self)

    self.utils = utils or addon.UtilsPrototype:new()
    self.types = { "PACK", "TRIGGER", "TIMER", "STATE", "EVENT", "RAID_FRAME_ICON", "SOUND" }

    return instance
end

function ImportValidator:validate(import)
    if type(import) ~= "table" then
        error("Import it not a table")
    end

    if not self.utils:isArray(import) then
        error("Import is not an array")
    end

    if not #import == 1 or import[1].type ~= "PACK" then
        error("Import can only contain one `PACK` item (for now)")
    end

    for _, item in pairs(import) do
        self:validateItem(item)
    end
    
    return true
end

function ImportValidator:validateItem(item, packItem)
    if not item.type then
        error("Item is missing `type`")
    end

    if not item.version then
        error("Item is missing `version`")
    end

    if packItem and item.type == "PACK" then
        error("Packs can not contain items of type `PACK`")
    end

    self:validateType(item)

    if item.type == "PACK" then
        self:validatePack(item)
    end

    if item.type == "TRIGGER" then
        self:validateTrigger(item)
    end

    if item.type == "TIMER" then
        self:validateTimer(item)
    end

    if item.type == "STATE" then
        self:validateState(item)
    end

    if item.type == "EVENT" then
        self:validateEvent(item)
    end

    if item.type == "RAID_FRAME_ICON" then
        self:validateRaidFrameIcon(item)
    end

    if item.type == "SOUND" then
        self:validateSound(item)
    end

    return true
end

function ImportValidator:validateType(item)
    if not self.utils:tableContains(self.types, item.type) then
        error("Item has an unknown type: " .. toString(item.type))
    end
end

function ImportValidator:validateEncounter(item)
    if not item.encounter then
        error("Item is missing encounter")
    end

    if not self.utils:isInteger(item.encounter) then
        error("Item has an invalid encounter: " .. toString(item.encounter))
    end
end

function ImportValidator:validatePack(item)
    if not item.name then
        error("Item of type `PACK` is missing name")
    end

    if not item.id then
        error("Item of type `PACK` is missing `id`")
    end

    if not item.packVersion then
        error("Item of type `PACK` is missing packVersion")
    end
    
    if not item.items then
        error("Item of type `PACK` is missing items")
    end

    if not self.utils:isArray(item.items) then
        error("Item of type `PACK` has an invalid `items` field. It should be a list")
    end

    if #item.items == 0 then
        error("Item of type `PACK` is missing items")
    end

    for _, item in ipairs(item.items) do
        self:validateItem(item, true)
    end
end

function ImportValidator:validateTrigger(item) 
    self:validateEncounter(item)

    if not item.id then
        error("Item of type `TRIGGER` is missing `id`")
    end

    if not item.triggers then
        error("Item of type `TRIGGER` is missing `triggers`")
    end

    if not self.utils:isArray(item.triggers) then
        error("Item of type `TRIGGER` has an invalid `triggers` field. It should be a list")
    end

    for _, trigger in ipairs(item.triggers) do
        self:validateRealTrigger(trigger)
    end

    if item.untriggers then
        if not self.utils:isArray(item.untriggers) then
            error("Item of type `TRIGGER` has an invalid `untriggers` field. It should be a list")
        end

        for _, untrigger in ipairs(item.untriggers) do
            self:validateRealTrigger(untrigger)
        end
    end
end

function ImportValidator:validateRealTrigger(trigger)
    if not trigger.type then
        error("Trigger is missing `type`")
    end

    if trigger.type == "UNIT_HEALTH" then
        self:validateUnitHealthTrigger(trigger)
    elseif trigger.type == "SPELL_AURA" then
        self:validateSpellAuraTrigger(trigger)
    elseif trigger.type == "SPELL_CAST" then
        self:validateSpellCastTrigger(trigger)
    elseif trigger.type == "EMOTE_OR_YELL" then
        self:validateEmoteOrYellTrigger(trigger)
    end

    if trigger.countdown and not self.utils:isInteger(trigger.countdown) then
        error("Trigger has an invalid `countdown` value")
    end

    if trigger.duration and not self.utils:isInteger(trigger.duration) then
        error("Trigger has an invalid `duration` value")
    end

    if trigger.delay and not self.utils:isInteger(trigger.delay) then
        error("Trigger has an invalid `delay` value")
    end

    if trigger.throttle and not self.utils:isInteger(trigger.throttle) then
        error("Trigger has an invalid `throttle` value")
    end
end

function ImportValidator:validateUnitHealthTrigger(trigger)
    if not trigger.unit then
        error("Trigger of type `UNIT_HEALTH` is missing `unit`")
    end

    local conditions = {}
    insert(conditions, trigger.lessThan)
    insert(conditions, trigger.greaterThan)
    insert(conditions, trigger.lessThanPct)
    insert(conditions, trigger.greaterThanPct)

    if not #conditions == 1 then
        error("Trigger of type `UNIT_HEALTH` requires exactly one condition (`lessThan`, `greaterThan`, ...)")
    end

    if not self.utils:isInteger(conditions[1]) then
        error("Trigger of type `UNIT_HEALTH` has an invalid condition value: " .. conditions[1])
    end
end

function ImportValidator:validateSpellAuraTrigger(trigger)
    if not trigger.spellId then
        error("Trigger of type `SPELL_AURA` is missing `spellId`")
    end

    if not self.utils:isInteger(trigger.spellId) then
        error("Trigger of type `SPELL_AURA` has an invalid `spellId")
    end
end

function ImportValidator:validateSpellCastTrigger(trigger)
    if not trigger.spellId then
        error("Trigger of type `SPELL_CAST` is missing `spellId`")
    end

    if not self.utils:isInteger(trigger.spellId) then
        error("Trigger of type `SPELL_AURA` has an invalid `spellId")
    end
end

function ImportValidator:validateEmoteOrYellTrigger(trigger)
    if not trigger.text then
        error("Trigger of type `EMOTE_OR_YELL` is missing `text`")
    end
end

function ImportValidator:validateTimer(item)
    self:validateEncounter(item)

    if not item.id then
        error("Item of type `TIMER` is missing `id`")
    end

    if not item.name then
        error("Item of type `TIMER` is missing `name`")
    end

    if not item.trigger then
        error("Item of type `TIMER` is missing `trigger`")
    end
end

function ImportValidator:validateState(item)
    self:validateEncounter(item)

    if not item.id then
        error("Item of type `STATE` is missing `id`")
    end

    if not item.name then
        error("Item of type `STATE` is missing `name`")
    end

    if not item.trigger then
        error("Item of type `STATE` is missing `trigger`")
    end
end

function ImportValidator:validateEvent(item)
    self:validateEncounter(item)

    if not item.id then
        error("Item of type `EVENT` is missing `id`")
    end

    if not item.name then
        error("Item of type `EVENT` is missing `name`")
    end

    if not item.trigger then
        error("Item of type `EVENT` is missing `trigger`")
    end
end

function ImportValidator:validateRaidFrameIcon(item)
    self:validateEncounter(item)

    if not item.id then
        error("Item of type `RAID_FRAME_ICON` is missing `id`")
    end

    if not item.trigger then
        error("Item of type `RAID_FRAME_ICON` is missing `trigger`")
    end

    if not item.icon then
        error("Item of type `RAID_FRAME_ICON` is missing `icon`")
    end
end

function ImportValidator:validateSound(item)
    self:validateEncounter(item)

    if not item.id then
        error("Item of type `SOUND` is missing `id`")
    end

    if not item.trigger then
        error("Item of type `SOUND` is missing `trigger`")
    end

    if item.sound and item.tts then
        error("Item of type `SOUND` has both `sound` and `tts`")
    end

    if not item.sound and not item.tts then
        error("Item of type `SOUND` is missing `sound` or `tts`")
    end
end
