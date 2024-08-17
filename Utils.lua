local gsub = string.gsub

local AntiRaidTools = AntiRaidTools

AntiRaidTools.UtilsPrototype = {}

local Utils = AntiRaidTools.UtilsPrototype
Utils.__index = Utils

function Utils:new()
    local instance = setmetatable({}, self)
    return instance
end

function Utils:tableContains(table, val)
    for _, v in ipairs(table) do
        if v == val then
            return true
        end
    end

    return false
end

function Utils:deepClone(val)
    local val_type = type(val)
    local copy

    if val_type == 'table' then
        copy = {}
        for k, v in next, val, nil do
            copy[self:deepClone(k)] = self:deepClone(v)
        end
        setmetatable(copy, self:deepClone(getmetatable(val)))
    else -- number, string, boolean, etc
        copy = val
    end

    return copy
end

function Utils:deepEqual(val1, val2)
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
        if not self:deepEqual(v, val2[k]) then
            return false
        end
    end

    return true
end

function Utils:isArray(table)
    local i = 0

    for _ in pairs(table) do
        i = i + 1
        if table[i] == nil then return false end
    end

    return true
end

function Utils:isInteger(number)
    if number and type(number) == "number" and number == math.floor(number) then
        return true
    end

    return false
end

function Utils:stringJoin(strings, delimiter)
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

function Utils:stringEllipsis(str, len)
    if string.len(str) > len + 3 then
        return str:sub(1, len) .. "..."
    end

    return str
end

-- Removed code line information from error messages
function Utils:stripErrorFileAndLine(errorMsg)
    return gsub(errorMsg, "^.+:%d+: ", "")
end

-- local random = math.random

-- function AntiRaidTools:GenerateUUID()
--     local chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
--     local base = #chars
--     local id = ''

--     for i = 1, 8 do
--         local rand = math.random(base)
--         id = id .. chars:sub(rand, rand)
--     end
        
--     return id
-- end

-- local fallbackColor = { r = 0, g = 0, b = 0 }

-- function AntiRaidTools:GetSpellColor(spellId)
--     local spell = self:SpellsGetSpell(spellId)

--     if not spell then
--         return fallbackColor
--     end

--     return self:GetClassColor(spell.class)
-- end

-- function AntiRaidTools:GetClassColor(class)
--     local color = RAID_CLASS_COLORS[class]

--     if not color then
--         return fallbackColor
--     end

--     return color
-- end

-- function AntiRaidTools:IsFriendlyRaidMemberOrPlayer(guid)
--     if UnitGUID("player") == guid then
--         return true
--     end

--     for i = 1, GetNumGroupMembers() do
--         local raidUnit = "raid" .. i

--         if UnitGUID(raidUnit) == guid then
--             return true
--         end
--     end

--     return false
-- end

-- function AntiRaidTools:CreateFadeOut(frame, onFinished)
--     local fadeOutGroup = frame:CreateAnimationGroup()

--     local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
--     fadeOut:SetFromAlpha(1)
--     fadeOut:SetToAlpha(0)
--     fadeOut:SetDuration(0.1)
--     fadeOut:SetSmoothing("OUT")

--     fadeOutGroup:SetScript("OnFinished", function(self)
--         if onFinished then onFinished() end
--         self:GetParent():Hide()
--     end)

--     return fadeOutGroup
-- end

-- function AntiRaidTools:ShallowCopy(table)
--     if not table then return nil end

--     local copy = {}

--     for k, v in pairs(table) do
--         copy[k] = v
--     end
    
--     return copy
-- end

-- function AntiRaidTools:StringEllipsis(str, len)
--     if string.len(str) > len + 3 then
--         return str:sub(1, len) .. "..."
--     end

--     return str
-- end

-- function AntiRaidTools:StringJoin(strings, delimiter)
--     delimiter = delimiter or ", "

--     local result = ""

--     for i, str in ipairs(strings) do
--         result = result .. str

--         if i < #strings then
--             result = result .. delimiter
--         end
--     end

--     return result
-- end

-- function AntiRaidTools:IsPlayerRaidLeader()
--     return IsInRaid() and UnitIsGroupLeader("player")
-- end

-- function AntiRaidTools:GetRaidAssignmentPart(uuid)
--     local encounters = self.db.profile.data.encounters

--     if encounters then
--         for _, encounter in pairs(encounters) do
--             for _, part in pairs(encounter) do
--                 if part.uuid == uuid then
--                     return part
--                 end
--             end
--         end
--     end
-- end

-- function AntiRaidTools:IsPlayerInAssignments(assignments)
--     for _, group in ipairs(assignments) do
--         for _, assignment in ipairs(group) do
--             if assignment.player == UnitName("player") then
--                 return true
--             end
--         end
--     end

--     return false
-- end

-- function AntiRaidTools:IsPlayerInActiveGroup(part)
--     local activeGroups = self:GroupsGetActive(part.uuid)

--     if activeGroups then
--         for _, groupIndex in ipairs(activeGroups) do
--             local group = part.assignments[groupIndex]
--             if group then
--                 for _, assignment in ipairs(group) do
--                     if assignment.player == UnitName("player") then
--                         return true
--                     end
--                 end
--             end
--         end
--     end

--     return false
-- end
