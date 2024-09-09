
local addonName, addon = ...

local gsub = string.gsub
local insert = table.insert

addon.UtilsPrototype = {}

local Utils = addon.UtilsPrototype
Utils.__index = Utils

function Utils:New()
    local instance = setmetatable({}, self)
    return instance
end

function Utils:TableContains(table, val)
    for _, v in ipairs(table) do
        if v == val then
            return true
        end
    end

    return false
end

function Utils:DeepClone(val)
    local val_type = type(val)
    local copy

    if val_type == 'table' then
        copy = {}
        for k, v in next, val, nil do
            copy[self:DeepClone(k)] = self:DeepClone(v)
        end
        setmetatable(copy, self:DeepClone(getmetatable(val)))
    else -- number, string, boolean, etc
        copy = val
    end

    return copy
end

function Utils:DeepEqual(val1, val2)
    if val1 == val2 then
        return true
    end

    if type(val1) ~= type(val2) then
        return false
    end

    if type(val1) ~= "table" then
        return false
    end

    -- Ensure both tables have the same number of keys
    for k in pairs(val1) do
        if val2[k] == nil then
            return false
        end
    end

    for k in pairs(val2) do
        if val1[k] == nil then
            return false
        end
    end

    -- Recursively compare elements of both tables
    for k, v in pairs(val1) do
        if not self:DeepEqual(v, val2[k]) then
            return false
        end
    end

    return true
end

function Utils:IsArray(table)
    local i = 0

    for _ in pairs(table) do
        i = i + 1
        if table[i] == nil then return false end
    end

    return true
end

function Utils:IsInteger(number)
    if number and type(number) == "number" and number == math.floor(number) then
        return true
    end

    return false
end

function Utils:StringJoin(strings, delimiter)
    delimiter = delimiter or ", "

    local result = ""

    for i, str in ipairs(strings) do
        result = result .. str

        if i < #strings then
            result = result .. delimiter
        end
    end

    return result
end

function Utils:StringEllipsis(str, len)
    if string.len(str) > len + 3 then
        return str:sub(1, len) .. "..."
    end

    return str
end

function Utils:StringInterpolate(str, ctx)
    local env = setmetatable(self:DeepClone(ctx), { __index = _G })

    return (str:gsub("%${(.-)}", function(expression)
        local func = loadstring("return " .. expression)

        if not func then
            return "???"
        end

        setfenv(func, env)

        local success, result = pcall(func)

        if success and result ~= nil then
            return tostring(result)
        else
            return "???"
        end
    end))
end

-- Removed code line information from error messages
function Utils:StripErrorFileAndLine(errorMsg)
    return gsub(errorMsg, "^.+:%d+: ", "")
end

function Utils:FilterTable(table, filterFunc)
    local result = {}
    
    for _, item in pairs(table) do
        if filterFunc(item) then
            insert(result, item)
        end
    end

    return result
end

-- keyFunc should return a key to group by.
-- Should probably return a string or number.
function Utils:GroupTable(table, keyFunc)
    local result = {}
    
    for _, item in pairs(table) do
        local key = keyFunc(item)

        if not result[key] then
            result[key] = {}
        end

        insert(result[key], item)
    end

    return result
end

function Utils:IsGameVersion(version)
    local gameVersion = select(4,GetBuildInfo())

    if version == "CATA" then
        return gameVersion >= 40000 and gameVersion < 50000
    end

    return false
end

function Utils:GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 15) or (random(8, 11))
        return string.format('%x', v)
    end)
end
