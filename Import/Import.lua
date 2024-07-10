local AntiRaidTools = AntiRaidTools
local insert = table.insert

function AntiRaidTools:ImportYAML(str)
    if str == nil or string.len(str) == 0 then
        return false
    end

    local ok, result = AntiRaidTools.YAML.evalm(str)

    if not ok then
        return false, "Error in document " .. result .. ": Failed to parse YAML."
    end

    for i, part in ipairs(result) do
        if type(part) ~= "table" then
            return false, "Error in document " .. i .. ": Invalid import."
        end
    end

    for i, part in ipairs(result) do
        local ok, result = AntiRaidTools:ValidationValidateImports(result)

        if not ok then
            return false, "Error in document " .. i .. ": " .. result
        end
    end

    for _, part in ipairs(result) do
        part.uuid = AntiRaidTools:GenerateUUID()
    end

    return true, result
end

function AntiRaidTools:ImportCreateEncountersData(import)
    local result = {}

    for _, part in ipairs(import) do
        if not result[part.encounter] then
            result[part.encounter] = {}
        end

        insert(result[part.encounter], part)
    end

    local uuid = self:GenerateUUID()

    return result, uuid
end

function AntiRaidTools:ImportCreateDefaults(import)
    for _, part in ipairs(import) do
        if part.type == "RAID_ASIGNMENTS" then
            if not part.untrigger then
                if part.strategy.type == "BEST_MATCH" then
                    part.untrigger = {
                        type = "TIMED",
                        duration = 5
                    }
                elseif part.strategy.type == "SHOW_ALL" then
                    part.untrigger = {
                        type = "ASSIGNMENTS_COMPLETE",
                    }
                end
            end
        end
    end
end
