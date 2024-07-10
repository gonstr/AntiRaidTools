local AntiRaidTools = AntiRaidTools

local deadCache = {}

function AntiRaidTools:UnitsSetDead(destGUID)
    deadCache[destGUID] = true
end

function AntiRaidTools:UnitsIsDead(destGUID)
    if deadCache[destGUID] then
        return true
    end

    return false
end

function AntiRaidTools:UnitsClearDead(destGUID)
    deadCache[destGUID] = nil
end

function AntiRaidTools:UnitsResetDeadCache()
    deadCache = {}
end
