local AntiRaidTools = AntiRaidTools

-- Key: Trigger UUID, value = true / false
local activeTriggers = {}

function AntiRaidTools:TriggersSetTriggered(uuid)
    activeTriggers[uuid] = true
end

function AntiRaidTools:TriggersSetUntriggered(uuid)
    activeTriggers[uuid] = false
end

function AntiRaidTools:TriggersGetTriggered(uuid)
    return activeTriggers[uuid] or false
end
