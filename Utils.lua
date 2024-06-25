local AntiRaidTools = AntiRaidTools

local random = math.random

function AntiRaidTools:GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end


local fallbackColor = { r = 0, g = 0, b = 0 }

function AntiRaidTools:GetSpellColor(spellId)
    local spell = self:GetSpell(spellId)

    if not spell then
        return fallbackColor
    end

    return self:GetClassColor(spell.class)
end

function AntiRaidTools:GetClassColor(class)
    local color = RAID_CLASS_COLORS[class]

    if not color then
        return fallbackColor
    end

    return color
end

function AntiRaidTools:IsFriendlyRaidMemberOrPlayer(guid)
    if UnitGUID("player") == guid then
        return true
    end

    for i = 1, GetNumGroupMembers() do
        local raidUnit = "raid" .. i

        if UnitGUID(raidUnit) == guid then
            return true
        end
    end

    return false
end

function AntiRaidTools:CreateFadeOut(frame, onFinished)
    local fadeOutGroup = frame:CreateAnimationGroup()

    local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("OUT")

    fadeOutGroup:SetScript("OnFinished", function(self)
        if onFinished then onFinished() end
        self:GetParent():Hide()
    end)

    return fadeOutGroup
end

function AntiRaidTools:ShallowCopyTable(table)
    if not table then return nil end

    local copy = {}

    for k, v in pairs(table) do
        copy[k] = v
    end
    
    return copy
end

function AntiRaidTools:StringEllipsis(str, len)
    if string.len(str) > len + 3 then
        return str:sub(1, len) .. "..."
    end

    return str
end
