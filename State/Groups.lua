local AntiRaidTools = AntiRaidTools

-- Key: UUID, value = assignment group index
local activeGroups = {}

function AntiRaidTools:GroupsSetActive(uuid, groups)
    activeGroups[uuid] = groups
end

function AntiRaidTools:GroupsGetActive(uuid)
    return activeGroups[uuid]
end

function AntiRaidTools:GroupsGetAllActive()
    return activeGroups
end

function AntiRaidTools:GroupsSetAllActive(groups)
    activeGroups = groups
end

function AntiRaidTools:GroupsReset()
    activeGroups = {}
end
