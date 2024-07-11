local AntiRaidTools = AntiRaidTools

-- Key: Trigger UUID, Value: timestamp
local activeTriggers = {}

function AntiRaidTools:TriggersSetTriggered(uuid, countdown)
    if not countdown then
        countdown = 0
    end

    activeTriggers[uuid] = GetTime() + countdown
end

function AntiRaidTools:TriggersSetUntriggered(uuid)
    activeTriggers[uuid] = false
end

function AntiRaidTools:TriggersGetTriggered(uuid)
    return activeTriggers[uuid] or false
end
