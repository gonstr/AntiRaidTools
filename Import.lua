local AntiRaidTools = AntiRaidTools
local insert = table.insert

function AntiRaidTools:ImportYAML(str)
    if str == nil or string.len(str) == 0 then
        return false
    end

    local ok, result = pcall(AntiRaidTools.YAML.evalm, str)

    if not ok then
        return false, "ParseError: " .. result or "Invalid import."
    end

    for _, part in ipairs(result) do
        if type(part) ~= "table" then
            return false, "ParseError: Invalid import."
        end
    end

    for _, part in ipairs(result) do
        local ok, result = AntiRaidTools:ValidateImports(result)

        if not ok then
            return false, "Invalid import: " .. result
        end
    end

    return true, result
end

function AntiRaidTools:GroupImportByEncounter(import)
    local result = {}

    for _, part in ipairs(import) do
        if not result[part.encounter] then
            result[part.encounter] = {}
        end

        insert(result[part.encounter], part)
    end

    return result
end
