local AntiRaidTools = AntiRaidTools

local activeCache = {}
local cooldownCache = {}

local spells = {
    -- Divine Hymn
    [64843] = {
        class = "PRIEST",
        cooldown = 60 * 8,
        duration = 8
    },
    -- Pain Suppression
    [33206] = {
        class = "PRIEST",
        cooldown = 60 * 3,
        duration = 8
    },
    -- Power Word: Barrier
    [62618] = {
        class = "PRIEST",
        cooldown = 60 * 3,
        duration = 10
    },
    -- Aura Mastery
    [31821] = {
        class = "PALADIN",
        cooldown = 60 * 2,
        duration = 6
    },
    -- Hand of Sacrifice
    [6940] = {
        class = "PALADIN",
        cooldown = 60 * 2,
        duration = 12
    },
    -- Tranquility
    [740] = {
        class = "DRUID",
        cooldown = 60 * 8,
        duration = 8
    },
    -- Stampeding Roar
    [77764] = {
        class = "DRUID",
        cooldown = 60 * 2,
        duration = 8
    },
    -- Spirit Link Totem
    [98008] = {
        class = "SHAMAN",
        cooldown = 60 * 3,
        duration = 6
    },
    -- Rallying Cry
    [97462] = {
        class = "WARRIOR",
        cooldown = 60 * 3,
        duration = 10
    },
    -- Anti-Magic Zone
    [51052] = {
        class = "DEATHKNIGHT",
        cooldown = 60 * 2,
        duration = 10
    }
}

function AntiRaidTools:ResetSpellsCache()
    activeCache = {}
    cooldownCache = {}
end

function AntiRaidTools:IsSpellReady(unit, spellId, timestamp)
    if UnitIsDeadOrGhost(unit) then
        return false
    end
    
    -- if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
    --     return false
    -- end
    
    timestamp = timestamp or GetTime()

    local key = unit .. ":" .. spellId

    local cachedTimestamp = cooldownCache[key]

    if not cachedTimestamp then
        return true
    end
    
    if timestamp < cachedTimestamp then
        return false
    end

    cooldownCache[key] = nil
    
    return true
end

function AntiRaidTools:IsSpellActive(unit, spellId)
    if UnitIsDeadOrGhost(unit) then
        return false
    end
    
    -- if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
    --     return false
    -- end

    timestamp = GetTime()

    local key = unit .. ":" .. spellId

    local cachedTimestamp = activeCache[key]

    if not cachedTimestamp then
        return false
    end
    
    if timestamp < cachedTimestamp then
        return true
    end

    activeCache[key] = nil
    
    return false
end

function AntiRaidTools:GetSpells()
    return spells
end

function AntiRaidTools:GetSpell(spellId)
    return spells[spellId]
end

function AntiRaidTools:GetSpellDuration(spellId)
    local spell = spell[spellId]
    
    if spell then
        return spell.duration
    end
    
    return nil
end

function AntiRaidTools:GetSpellCooldown(spellId)
    local spell = spell[spellId]
    
    if spell then
        return spell.cooldown
    end
    
    return nil
end

function AntiRaidTools:CacheSpellCast(unit, spellId, updateFunc)
    if UnitIsPlayer(unit) or UnitInRaid(unit) then
        local spell = spells[spellId]
        
        if spell then
            local key = unit .. ":" .. spellId

            activeCache[key] = GetTime() + spell.duration
            cooldownCache[key] = GetTime() + spell.cooldown

            updateFunc()
            C_Timer.After(spell.duration, updateFunc)
            C_Timer.After(spell.cooldown, updateFunc)
        end
    end
end
