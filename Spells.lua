local AntiRaidTools = AntiRaidTools

local cooldownCache = {}

local spells = {
    -- Divine Hymn
    [64843] = {
        cooldown = 60 * 8,
        duration = 8
    },
    -- Pain Suppression
    [33206] = {
        cooldown = 60 * 3,
        duration = 8
    },
    -- Power Word: Barrier
    [98888] = {
        cooldown = 60 * 3,
        duration = 10
    },
    -- Aura Mastery
    [31821] = {
        cooldown = 60 * 2,
        duration = 6
    },
    -- Hand of Sacrifice
    [6940] = {
        cooldown = 60 * 2,
        duration = 12
    },
    -- Tranquility
    [740] = {
        cooldown = 60 * 8,
        duration = 8
    },
    -- Spirit Link Totem
    [98008] = {
        cooldown = 60 * 3,
        duration = 6
    },
    -- Rallying Cry
    [97462] = {
        cooldown = 60 * 3,
        duration = 10
    },
    -- Anti-Magic Zone
    [51052] = {
        cooldown = 60 * 2,
        duration = 10
    },
    -- Stampeding Roar
    [77764] = {
        cooldown = 60 * 2,
        duration = 8
    }
}

function AntiRaidTools:ResetCooldowns()
    cooldownCache = {}
end

function AntiRaidTools:IsSpellAvailable(unit, spellId, timestamp)
    if UnitIsDeadOrGhost(unit) then
        return false
    end
    
    if not UnitInRaid(unit) then
        return false
    end
    
    local cooldown = cooldownCache[unit .. ":" .. spellId] 
    
    if cooldown and timestamp < cooldown then
        return false
    end
    
    return true
end

function AntiRaidTools:GetSpells()
    return spells
end

function AntiRaidTools:GetSpellDuration(spellId)
    local spell = spell[spellId]
    
    if spell then
        return spell.duration
    end
    
    return nil
end
