local AntiRaidTools = AntiRaidTools

local cooldowns = {}

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

function AntiRaidTools:ResetCooldowns()
    cooldowns = {}
end

function AntiRaidTools:IsSpellReady(unit, spellId, timestamp)
    return true

    -- if UnitIsDeadOrGhost(unit) then
    --     return false
    -- end
    
    -- if not UnitInRaid(unit) then
    --     return false
    -- end
    
    -- timestamp = timestamp or GetTime()

    -- local cooldown = cooldowns[unit .. ":" .. spellId] 
    
    -- if cooldown and timestamp < cooldown then
    --     return false
    -- end
    
    -- return true
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

function AntiRaidTools:RegisterSpellCast(unit, spellId)
    if UnitIsPlayer(unit) or UnitInRaid(unit) then
        local spell = spells[spellId]
        
        if spell then
            cooldowns[unit .. ":" .. spellId] = GetTime() + spell.cooldown
        end
    end
end
