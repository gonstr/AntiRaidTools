local addonName, addon = ...

local insert = table.insert

addon.ImportValidatorPrototype = {}

local ImportValidator = addon.ImportValidatorPrototype
ImportValidator.__index = ImportValidator

local function TableToString(maybeTable, indent)
    if type(maybeTable) ~= "table" then
        return maybeTable or ""
    end

    local result = {}
    local indent = indent or 0
    local padding = string.rep("  ", indent)
    
    table.insert(result, "{\n")
    
    for k, v in pairs(maybeTable) do
        local key
        if type(k) == "string" then
            key = string.format("%s[%q] = ", padding, k)
        else
            key = string.format("%s[%s] = ", padding, TableToString(k))
        end
        
        local value
        if type(v) == "table" then
            value = TableToString(v, indent + 1)
        elseif type(v) == "string" then
            value = string.format("%q", v)
        else
            value = TableToString(v)
        end
        
        table.insert(result, key .. value .. ",\n")
    end
    
    table.insert(result, padding .. "}")
    
    return table.concat(result)
end

function ImportValidator:New(utils)
    local instance = setmetatable({}, self)

    instance.utils = utils or addon.UtilsPrototype:New()
    instance.itemTypes = { "PACK", "TRIGGER", "TIMER", "STATE", "EVENT", "RAID_FRAME_ICON", "SOUND" }
    instance.optionTypes = { "TOGGLE" }
    instance.gameVersions = { "CATA" }

    return instance
end

function ImportValidator:Validate(import)
    if type(import) ~= "table" then
        error("Import it not a table")
    end

    if not self.utils:IsArray(import) then
        error("Import is not an array")
    end

    if not #import == 1 or import[1].type ~= "PACK" then
        error("Import can only contain one `PACK` item (for now)")
    end

    for _, item in pairs(import) do
        self:ValidateItem(item)
    end
    
    return true
end

function ImportValidator:ValidateItem(item, packItem)
    if not item.type then
        error("Item is missing `type`")
    end

    if not item.version then
        error("Item is missing `version`")
    end

    if packItem and item.type == "PACK" then
        error("Packs can not contain items of type `PACK`")
    end

    self:ValidateType(item)

    if item.type == "PACK" then
        self:ValidatePack(item)
    end

    if item.type == "TRIGGER" then
        self:ValidateTrigger(item)
    end

    if item.type == "TIMER" then
        self:ValidateTimer(item)
    end

    if item.type == "STATE" then
        self:ValidateState(item)
    end

    if item.type == "EVENT" then
        self:ValidateEvent(item)
    end

    if item.type == "RAID_FRAME_ICON" then
        self:ValidateRaidFrameIcon(item)
    end

    if item.type == "SOUND" then
        self:ValidateSound(item)
    end

    return true
end

function ImportValidator:ValidateType(item)
    if not self.utils:TableContains(self.itemTypes, item.type) then
        error("Item has an unknown type: " .. TableToString(item.type))
    end
end

function ImportValidator:ValidateEncounter(item)
    if not item.encounter then
        error("Item is missing encounter")
    end

    if not self.utils:IsInteger(item.encounter) then
        error("Item has an invalid encounter: " .. TableToString(item.encounter))
    end
end

function ImportValidator:ValidatePackOptions(options)
    if not options.headerTexture then
        error("Item of type `PACK` is missing `headerTexture`")
    end

    if not options.headerTexCords then
        error("Item of type `PACK` is missing `headerTexCords`")
    end

    if not self.utils:IsArray(options.headerTexCords) then
        error("Item of type `PACK` has invalid header texture coordinates")
    end

    if #options.headerTexCords ~= 4 and #options.headerTexCords ~= 8 then
        error("Item of type `PACK` has invalid header texture coordinates")
    end

    if not options.groups then
        error("Item of type `PACK` is missing `groups`")
    end

    if not self.utils:IsArray(options.groups) then
        error("Item of type `PACK` has an invalid `groups` field. It should be an array")
    end

    if #options.groups == 0 then
        error("Item of type `PACK` is missing `groups`")
    end

    for _, group in ipairs(options.groups) do
        if not group.header then
            error("Item of type `PACK` has an options group without `header`")
        end

        if not group.items then
            error("Item of type `PACK` has an options group without `items`")
        end
    
        if not self.utils:IsArray(group.items) then
            error("Item of type `PACK` has an invalid `items` field. It should be an array")
        end

        if #group.items == 0 then
            error("Item of type `PACK` has an options group without `items`")
        end

        for _, item in ipairs(group.items) do
            if not item.type then
                error("Item of type `PACK` is missing `type` in a options item")
            end

            if not self.utils:TableContains(self.optionTypes, item.type) then
                error("Item has an unknown type: " .. TableToString(item.type))
            end

            if not item.name then
                error("Item of type `PACK` is missing `name` in a options item")
            end

            if not item.description then
                error("Item of type `PACK` is missing `description` in a options item")
            end

            if not item.id then
                error("Item of type `PACK` is missing `id` in a options item")
            end

            if not item.default then
                error("Item of type `PACK` is missing `default` in a options item")
            end
        end
    end
end


function ImportValidator:ValidatePack(item)
    if not item.name then
        error("Item of type `PACK` is missing name")
    end

    if not item.id then
        error("Item of type `PACK` is missing `id`")
    end

    if not item.gameVersion then
        error("Item of type `PACK` is missing `gameVersion`")
    end

    if not self.utils:TableContains(self.gameVersions, item.gameVersion) then
        error("Item has an unknown gameVersion: " .. TableToString(item.type))
    end

    if not self.utils:IsGameVersion(item.gameVersion) then
        error("Item of type `PACK` has a non matching game version")
    end

    if not item.packVersion then
        error("Item of type `PACK` is missing packVersion")
    end
    
    if not item.items then
        error("Item of type `PACK` is missing items")
    end

    if not self.utils:IsArray(item.items) then
        error("Item of type `PACK` has an invalid `items` field. It should be an array")
    end

    if #item.items == 0 then
        error("Item of type `PACK` is missing items")
    end

    for _, item in ipairs(item.items) do
        self:ValidateItem(item, true)
    end

    if item.options then
        self:ValidatePackOptions(item.options)
    end
end

function ImportValidator:ValidateTrigger(item) 
    self:ValidateEncounter(item)

    if not item.id then
        error("Item of type `TRIGGER` is missing `id`")
    end

    if not item.triggers then
        error("Item of type `TRIGGER` is missing `triggers`")
    end

    if not self.utils:IsArray(item.triggers) then
        error("Item of type `TRIGGER` has an invalid `triggers` field. It should be a list")
    end

    for _, trigger in ipairs(item.triggers) do
        self:ValidateRealTrigger(trigger)
    end

    if item.untriggers then
        if not self.utils:IsArray(item.untriggers) then
            error("Item of type `TRIGGER` has an invalid `untriggers` field. It should be a list")
        end

        for _, untrigger in ipairs(item.untriggers) do
            self:ValidateRealTrigger(untrigger)
        end
    end
end

function ImportValidator:ValidateRealTrigger(trigger)
    if not trigger.type then
        error("Trigger is missing `type`")
    end

    if trigger.type == "UNIT_HEALTH" then
        self:ValidateUnitHealthTrigger(trigger)
    elseif trigger.type == "SPELL_AURA" then
        self:ValidateSpellAuraTrigger(trigger)
    elseif trigger.type == "SPELL_CAST" then
        self:ValidateSpellCastTrigger(trigger)
    elseif trigger.type == "EMOTE_OR_YELL" then
        self:ValidateEmoteOrYellTrigger(trigger)
    end

    if trigger.countdown and not self.utils:IsInteger(trigger.countdown) then
        error("Trigger has an invalid `countdown` value")
    end

    if trigger.duration and not self.utils:IsInteger(trigger.duration) then
        error("Trigger has an invalid `duration` value")
    end

    if trigger.delay and not self.utils:IsInteger(trigger.delay) then
        error("Trigger has an invalid `delay` value")
    end

    if trigger.throttle and not self.utils:IsInteger(trigger.throttle) then
        error("Trigger has an invalid `throttle` value")
    end
end

function ImportValidator:ValidateUnitHealthTrigger(trigger)
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

    if not self.utils:IsInteger(conditions[1]) then
        error("Trigger of type `UNIT_HEALTH` has an invalid condition value: " .. conditions[1])
    end
end

function ImportValidator:ValidateSpellAuraTrigger(trigger)
    if not trigger.spellId then
        error("Trigger of type `SPELL_AURA` is missing `spellId`")
    end

    if not self.utils:IsInteger(trigger.spellId) then
        error("Trigger of type `SPELL_AURA` has an invalid `spellId`")
    end
end

function ImportValidator:ValidateSpellCastTrigger(trigger)
    if not trigger.spellId then
        error("Trigger of type `SPELL_CAST` is missing `spellId`")
    end

    if not self.utils:IsInteger(trigger.spellId) then
        error("Trigger of type `SPELL_AURA` has an invalid `spellId`")
    end
end

function ImportValidator:ValidateEmoteOrYellTrigger(trigger)
    if not trigger.text then
        error("Trigger of type `EMOTE_OR_YELL` is missing `text`")
    end
end

function ImportValidator:ValidateTimer(item)
    self:ValidateEncounter(item)

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

function ImportValidator:ValidateState(item)
    self:ValidateEncounter(item)

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

function ImportValidator:ValidateEvent(item)
    self:ValidateEncounter(item)

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

function ImportValidator:ValidateRaidFrameIcon(item)
    self:ValidateEncounter(item)

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

function ImportValidator:ValidateSound(item)
    self:ValidateEncounter(item)

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
