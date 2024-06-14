local AntiRaidTools = AntiRaidTools

local function stringSafe(thing, indent)
    if type(thing) ~= "table" then
        return thing
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
    if import.type ~= "RAID_CDS" then
        return false, "Import has an unknown type: " .. stringSafe(import.type) .. ". Supported types are `RAID_CDS`."
    end

    return true
end

local function validateEncounter(import)
    if type(import.encounter) ~= "number" or import.encounter ~= math.floor(import.encounter) then
        return false, "Import has an invalid encounter value: " .. stringSafe(import.encounter) .. ".."
    end

    return true
end

local function validateRaidCDs(import, spells)
    if import.type == "RAID_CDS" then
        if not import.raid_cds then
            return false, "Import with type RAID_CDS is missing a raid_cds field."
        end

        if type(import.raid_cds) ~= "table" then
            return false, "Import has an invalid raid_cds value: " .. stringSafe(import.raid_cds) .. "."
        end

        if not import.trigger then
            return false, "Import with type RAID_CDS is missing a trigger field."
        end

        if not import.spell_id then
            return false, "Import with type RAID_CDS is missing a spell_id field."
        end

        if type(import.spell_id) ~= "number" or import.spell_id ~= math.floor(import.spell_id) then
            return false, "Import has an invalid spell_id value: " .. stringSafe(import.spell_id) .. "."
        end

        for _, raid_cds_group in pairs(import.raid_cds) do
            if type(raid_cds_group) ~= "table" then
                return false, "Import has an invalid raid_cds value: " .. stringSafe(raid_cds_group) .. "."
            end

            for _, raid_cd in pairs(raid_cds_group) do
                if type(raid_cd) ~= "table" then
                    return false, "Import has an invalid raid_cds value: " .. stringSafe(raid_cd) .. "."
                end

                if not raid_cd.player then
                    return false, "Import has a malformed raid_cds field. Missing player: " .. stringSafe(raid_cd)
                end
                if not raid_cd.spell_id then
                    return false, "Import has a malformed raid_cds field. Missing spell_id: " .. stringSafe(raid_cd)
                end
                if type(raid_cd.spell_id) ~= "number" or raid_cd.spell_id ~= math.floor(raid_cd.spell_id) then
                    return false, "Import has an unknown spell_id value: " .. stringSafe(raid_cd.spell_id) .. "."
                end
                if not spells[raid_cd.spell_id] then
                    return false, "Import has a spell_id that's not supported (yet): " .. stringSafe(raid_cd.spell_id) .. "."
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

        if import.trigger.type ~= "FOJJI_NUMEN_TIMER" and import.trigger.type ~= "UNIT_HEALTH" then
            return false, "Import trigger has an unknown type. Valid types are `FOJJI_NUMEN_TIMER` and `UNIT_HEALTH`"
        end

        if import.trigger.type == "FOJJI_NUMEN_TIMER" then
            if not import.trigger.key then
                return false, "Import with trigger type FOJJI_NUMEN_TIMER is missing a key field."
            end
        end

        if import.trigger.type == "UNIT_HEALTH" then
            if not import.trigger.key then
                return false, "Import with trigger type UNIT_HEALTH is missing a unit field."
            end

            if not import.trigger.percentage then
                return false, "Import with trigger type UNIT_HEALTH is missing a percentage field."
            end
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

        ok, err = validateRaidCDs(import, spells)
        if not ok then return false, err end
    end
    
    return true
end
