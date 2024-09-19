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

function ImportValidator:New()
    local instance = setmetatable({}, self)

    instance.itemTypes = { "PACK", "TRIGGER", "EVENT", "UNIT_FRAME_ICON", "UNIT_FRAME_GLOW", "COMM", "SOUND" }
    instance.commChannels = { "SAY", "YELL" }
    instance.glowTypes = { "AUTOCAST", "PIXEL", "BUTTON" }
    instance.optionTypes = { "TOGGLE" }
    instance.gameVersions = { "CATA" }

    return instance
end

function ImportValidator:Validate(import)
    if type(import) ~= "table" then
        error("Import it not a table")
    end

    if not addon.utils:IsArray(import) then
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

    if item.type == "EVENT" then
        self:ValidateEvent(item)
    end

    if item.type == "COMM" then
        self:ValidateComm(item)
    end

    if item.type == "UNIT_FRAME_ICON" then
        self:ValidateUnitFrameIcon(item)
    end

    if item.type == "UNIT_FRAME_GLOW" then
        self:ValidateUnitFrameGlow(item)
    end

    if item.type == "SOUND" then
        self:ValidateSound(item)
    end

    return true
end

function ImportValidator:ValidateType(item)
    if not addon.utils:TableContains(self.itemTypes, item.type) then
        error("Item has an unknown type: " .. TableToString(item.type))
    end
end

function ImportValidator:ValidateEncounter(item)
    if not item.encounter then
        error("Item is missing encounter")
    end

    if not addon.utils:IsInteger(item.encounter) then
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

    if not addon.utils:IsArray(options.headerTexCords) then
        error("Item of type `PACK` has invalid header texture coordinates")
    end

    if #options.headerTexCords ~= 4 and #options.headerTexCords ~= 8 then
        error("Item of type `PACK` has invalid header texture coordinates")
    end

    if not options.groups then
        error("Item of type `PACK` is missing `groups`")
    end

    if not addon.utils:IsArray(options.groups) then
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
    
        if not addon.utils:IsArray(group.items) then
            error("Item of type `PACK` has an invalid `items` field. It should be an array")
        end

        if #group.items == 0 then
            error("Item of type `PACK` has an options group without `items`")
        end

        for _, item in ipairs(group.items) do
            if not item.type then
                error("Item of type `PACK` is missing `type` in a options item")
            end

            if not addon.utils:TableContains(self.optionTypes, item.type) then
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

    if not addon.utils:TableContains(self.gameVersions, item.gameVersion) then
        error("Item has an unknown gameVersion: " .. TableToString(item.type))
    end

    if not addon.utils:IsGameVersion(item.gameVersion) then
        error("Item of type `PACK` has a non matching game version")
    end

    if not item.packVersion then
        error("Item of type `PACK` is missing packVersion")
    end
    
    if not item.items then
        error("Item of type `PACK` is missing items")
    end

    if not addon.utils:IsArray(item.items) then
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

    if not addon.utils:IsArray(item.triggers) then
        error("Item of type `TRIGGER` has an invalid `triggers` field. It should be a list")
    end

    for _, trigger in ipairs(item.triggers) do
        self:ValidateRealTrigger(trigger)
    end

    if item.untriggers then
        if not addon.utils:IsArray(item.untriggers) then
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

    if trigger.countdown and not addon.utils:IsInteger(trigger.countdown) then
        error("Trigger has an invalid `countdown` value")
    end

    if trigger.duration and not addon.utils:IsInteger(trigger.duration) then
        error("Trigger has an invalid `duration` value")
    end

    if trigger.delay and not addon.utils:IsInteger(trigger.delay) then
        error("Trigger has an invalid `delay` value")
    end

    if trigger.throttle and not addon.utils:IsInteger(trigger.throttle) then
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

    if not addon.utils:IsInteger(conditions[1]) then
        error("Trigger of type `UNIT_HEALTH` has an invalid condition value: " .. conditions[1])
    end
end

function ImportValidator:ValidateSpellAuraTrigger(trigger)
    if not trigger.spellId then
        error("Trigger of type `SPELL_AURA` is missing `spellId`")
    end

    if not addon.utils:IsInteger(trigger.spellId) then
        error("Trigger of type `SPELL_AURA` has an invalid `spellId`")
    end
end

function ImportValidator:ValidateSpellCastTrigger(trigger)
    if not trigger.spellId then
        error("Trigger of type `SPELL_CAST` is missing `spellId`")
    end

    if not addon.utils:IsInteger(trigger.spellId) then
        error("Trigger of type `SPELL_AURA` has an invalid `spellId`")
    end
end

function ImportValidator:ValidateEmoteOrYellTrigger(trigger)
    if not trigger.text then
        error("Trigger of type `EMOTE_OR_YELL` is missing `text`")
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

    if item.highlight then
        if not addon.utils:IsArray(item.highlight) then
            error("Item has an unknown highlight field: " .. TableToString(item.highlight))
        end

        if #item.highlight ~= 4 then
            error("Item has an unknown highlight field: " .. TableToString(item.highlight))
        end
    end
end

function ImportValidator:ValidateComm(item)
    self:ValidateEncounter(item)

    if not item.id then
        error("Item of type `COMM` is missing `id`")
    end

    if not item.trigger then
        error("Item of type `COMM` is missing `trigger`")
    end

    if not item.type then
        error("Item of type `COMM` is missing `type`")
    end

    if not addon.utils:TableContains(self.commChannels, item.channel) then
        error("Item has an unknown channel: " .. TableToString(item.channel))
    end

    if not item.text then
        error("Item of type `COMM` is missing `text`")
    end
end

function ImportValidator:ValidateUnitFrameIcon(item)
    self:ValidateEncounter(item)

    if not item.id then
        error("Item of type `UNIT_FRAME_ICON` is missing `id`")
    end

    if not item.trigger then
        error("Item of type `UNIT_FRAME_ICON` is missing `trigger`")
    end
end

function ImportValidator:ValidateUnitFrameGlow(item)
    self:ValidateEncounter(item)

    if not item.id then
        error("Item of type `UNIT_FRAME_GLOW` is missing `id`")
    end

    if not item.trigger then
        error("Item of type `UNIT_FRAME_GLOW` is missing `trigger`")
    end

    if not item.glow then
        error("Item of type `UNIT_FRAME_GLOW` is missing `type`")
    end

    if not addon.utils:TableContains(self.glowTypes, item.glow) then
        error("Item has an unknown glow type: " .. TableToString(item.glow))
    end

    if item.color then
        if not addon.utils:IsArray(item.color) then
            error("Item has an unknown color field: " .. TableToString(item.color))
        end

        if #item.color ~= 4 then
            error("Item has an unknown color field: " .. TableToString(item.color))
        end
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

    if not item.file and not item.tts then
        error("Item of type `SOUND` is missing both `file` and `tts`")
    end
end
