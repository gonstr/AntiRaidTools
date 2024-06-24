local AntiRaidTools = AntiRaidTools

local deadCache = {}

function AntiRaidTools:CacheUnitDied(destGUID)
    deadCache[destGUID] = true
end

function AntiRaidTools:IsCachedUnitDead(destGUID)
    if deadCache[destGUID] then
        return true
    end

    return false
end

function AntiRaidTools:ClearCachedUnitDead(destGUID)
    deadCache[destGUID] = nil
end

function AntiRaidTools:ResetDeadCache()
    deadCache = nil
end
