local AntiRaidTools = AntiRaidTools

-- Key: UUID, value = assignment group index
local activeGroups = {}

function AntiRaidTools:SetActiveGroup(uuid, groups)
    activeGroups[uuid] = groups
end

function AntiRaidTools:GetActiveGroups(uuid)
    return activeGroups[uuid]
end

function AntiRaidTools:GetAllActiveGroups()
    return activeGroups
end

function AntiRaidTools:SetAllActiveGroups(groups)
    activeGroups = groups
end

function AntiRaidTools:ResetGroups()
    activeGroups = {}
end
