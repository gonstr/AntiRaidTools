local AntiRaidTools = AntiRaidTools

--- key = "unitId:spellId", Value = cast timestamp
local spellCastCache = {}

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

function AntiRaidTools:SpellsResetCache()
    spellCastCache = {}
end

function AntiRaidTools:SpellsIsSpellReady(unit, spellId, timestamp)
    if not self.TEST then
        if UnitIsDeadOrGhost(unit) then
            return false
        end

        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return false
        end
    end

    timestamp = timestamp or GetTime()

    local key = unit .. ":" .. spellId

    local cachedCastTimestamp = spellCastCache[key]

    if not cachedCastTimestamp then
        return true
    end

    if timestamp < cachedCastTimestamp + spells[spellId].cooldown then
        return false
    end

    return true
end

function AntiRaidTools:SpellsIsSpellActive(unit, spellId)
    if not self.TEST then
        if UnitIsDeadOrGhost(unit) then
            return false
        end

        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return false
        end
    end

    local timestamp = GetTime()

    local key = unit .. ":" .. spellId

    local cachedCastTimestamp = spellCastCache[key]

    if not cachedCastTimestamp then
        return false
    end

    if timestamp < cachedCastTimestamp + spells[spellId].duration then
        return true
    end

    return false
end

function AntiRaidTools:SpellsGetCastTimestamp(unit, spellId)
    local key = unit .. ":" .. spellId

    return spellCastCache[key]
end

function AntiRaidTools:SpellsGetAll()
    return spells
end

function AntiRaidTools:SpellsGetSpell(spellId)
    return spells[spellId]
end

function AntiRaidTools:SpellsCacheCast(unit, spellId, updateFunc)
    if not self.TEST then
        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return
        end
    end

    local spell = spells[spellId]

    if spell then
        local key = unit .. ":" .. spellId

        spellCastCache[key] = GetTime()

        updateFunc()
        C_Timer.After(spell.duration, updateFunc)
        C_Timer.After(spell.cooldown, updateFunc)
    end
end
