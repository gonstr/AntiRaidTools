local AntiRaidTools = AntiRaidTools

local function stringSafe(thing, indent)
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
            key = string.format("%s[%s] = ", padding, tostring(k))
        end
        
        local value
        if type(v) == "table" then
            value = stringSafe(v, indent + 1)
        elseif type(v) == "string" then
            value = string.format("%q", v)
        else
            value = tostring(v)
        end
        
        table.insert(result, key .. value .. ",\n")
    end
    
    table.insert(result, padding .. "}")
    
    return table.concat(result)
end

local function validateRequiredFields(import)
    if not import.type then
        return false, "Import is missing a type field"
    end
    if not import.encounter then
        return false, "Import is missing an encounter field"
    end

    return true
end

local function validateType(import)
    if import.type ~= "RAID_ASSIGNMENTS" then
        return false, "Import has an unknown type: " .. stringSafe(import.type) .. ". Supported values are `RAID_ASSIGNMENTS`."
    end

    return true
end

local function validateEncounter(import)
    if type(import.encounter) ~= "number" or import.encounter ~= math.floor(import.encounter) then
        return false, "Import has an invalid encounter value: " .. stringSafe(import.encounter) .. ".."
    end

    return true
end

local function validateRaidAssignments(import, spells)
    if import.type == "RAID_ASSIGNMENTS" then
        if not import.assignments then
            return false, "Import with type RAID_ASSIGNMENTS is missing a assignments field."
        end

        if type(import.assignments) ~= "table" then
            return false, "Import has an invalid assignments value: " .. stringSafe(import.assignments) .. "."
        end

        for _, group in ipairs(import.assignments) do
            if type(group) ~= "table" then
                return false, "Import has an invalid assignments value: " .. stringSafe(group) .. "."
            end
        end

        if not import.trigger then
            return false, "Import with type RAID_ASSIGNMENTS is missing a trigger field."
        end

        if not import.metadata then
            return false, "Import with type RAID_ASSIGNMENTS is missing a metadata field."
        end

        if not import.metadata.spell_id and not import.metadata.name then
            return false, "Import has an invalid metadata field. Requires spell_id or name."
        end

        if import.metadata.spell_id and (type(import.metadata.spell_id) ~= "number" or import.metadata.spell_id ~= math.floor(import.metadata.spell_id)) then
            return false, "Import has an invalid spell_id value: " .. stringSafe(import.spell_id) .. "."
        end

        if not import.strategy then
            return false, "Import with type RAID_ASSIGNMENTS is missing a strategy field."
        end

        if type(import.strategy) ~= "table" then
            return false, "Import has an invalid strategy value: " .. stringSafe(import.strategy) .. "."
        end

        if not import.strategy.type then
            return false, "Import has an invalid strategy field. Requires type."
        end

        if import.strategy.type ~= "BEST_MATCH" and import.strategy.type ~= "CHAIN" then
            return false, "Import has an unknown strategy: " .. stringSafe(import.strategy.type) .. ". Supported values are `BEST_MATCH`, `CHAIN`."
        end

        if not import.assignments then
            return false, "Import with type RAID_ASSIGNMENTS is missing an assignments field."
        end

        if type(import.assignments) ~= "table" then
            return false, "Import has an invalid assignments value: " .. stringSafe(import.assignments) .. "."
        end

        if table.getn(import.assignments) == 0 then
            return false, "Import assignments is empty."
        end
        
        for _, group in pairs(import.assignments) do
            if type(group) ~= "table" then
                return false, "Import has an invalid assignments value: " .. stringSafe(group) .. "."
            end

            if #group > 2 then
                return false, "Import has invalid assignments: " .. stringSafe(group) .. ". The group size is more than 2."
            end

            for _, assignment in pairs(group) do
                if type(assignment) ~= "table" then
                    return false, "Import has an invalid assignments value: " .. stringSafe(assignment) .. "."
                end

                if not assignment.type then
                    return false, "Import has a invalid assignments field. Missing type: " .. stringSafe(assignment)
                end

                if not assignment.player then
                    return false, "Import has a invalid assignments field. Missing player: " .. stringSafe(assignment)
                end
                if not assignment.spell_id then
                    return false, "Import has a invalid assignments field. Missing spell_id: " .. stringSafe(assignment)
                end
                if type(assignment.spell_id) ~= "number" or assignment.spell_id ~= math.floor(assignment.spell_id) then
                    return false, "Import has an unknown spell_id value: " .. stringSafe(assignment.spell_id) .. "."
                end
                if not spells[assignment.spell_id] then
                    return false, "Import has a spell_id that's not supported (yet): " .. stringSafe(assignment.spell_id) .. "."
                end
            end
        end
    end

    return true
end

local function validateTrigger(import)
    if import.trigger then
        if not import.trigger.type then
            return false, "Import trigger is missing a type field."
        end

        if import.trigger.type == "UNIT_HEALTH" then
            if not import.trigger.unit then
                return false, "Import with trigger type UNIT_HEALTH is missing a unit field."
            end

            if not import.trigger.percentage then
                return false, "Import with trigger type UNIT_HEALTH is missing a percentage field."
            end
        end

        if import.trigger.type == "SPELL_CAST" then
            if not import.trigger.spell_id then
                return false, "Import with trigger type SPELL_CAST is missing a spell_id field."
            end

            if type(import.trigger.spell_id) ~= "number" or import.trigger.spell_id ~= math.floor(import.trigger.spell_id) then
                return false, "Import has an invalid spell_id value: " .. stringSafe(import.trigger.spell_id) .. "."
            end
        end

        if import.trigger.type == "RAID_BOSS_EMOTE" then
            if not import.trigger.text then
                return false, "Import with trigger type UNIT_HEALTH is missing a text field."
            end
        end

        if import.trigger.type == "FOJJI_NUMEN_TIMER" then
            if not import.trigger.key then
                return false, "Import with trigger type FOJJI_NUMEN_TIMER is missing a key field."
            end

            if import.trigger.countdown then
                return false, "Import with trigger type FOJJI_NUMEN_TIMER has a countdown field."
            end
        end

        if import.trigger.countdown and (type(import.trigger.countdown) ~= "number" or import.trigger.countdown ~= math.floor(import.trigger.countdown)) then
            return false, "Import has an invalid countdown value: " .. stringSafe(import.trigger.countdown) .. "."
        end

        if import.trigger.duration and (type(import.trigger.duration) ~= "number" or import.trigger.duration ~= math.floor(import.trigger.duration)) then
            return false, "Import has an invalid duration field: " .. stringSafe(import.trigger.duration) .. "."
        end
    end

    return true
end

function AntiRaidTools:ValidateImports(imports)
    local spells = self:GetSpells()

    for _, import in pairs(imports) do
        local ok, err = validateRequiredFields(import)
        if not ok then return false, err end
        
        ok, err = validateType(import)
        if not ok then return false, err end
        
        ok, err = validateEncounter(import)
        if not ok then return false, err end

        ok, err = validateTrigger(import)
        if not ok then return false, err end

        ok, err = validateRaidAssignments(import, spells)
        if not ok then return false, err end
    end
    
    return true
end
